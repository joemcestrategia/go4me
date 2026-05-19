import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@13.11.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;

serve(async (req) => {
  const signature = req.headers.get("stripe-signature");
  if (!signature) return new Response("No signature", { status: 400 });

  try {
    const body = await req.text();
    const event = await stripe.webhooks.constructEventAsync(body, signature, webhookSecret);

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    switch (event.type) {
      case "payment_intent.succeeded": {
        const paymentIntent = event.data.object;
        const donationId = paymentIntent.metadata?.donation_id;

        if (donationId) {
          await supabase.from("donations").update({ status: "completed" }).eq("id", donationId);
        } else {
          const { data: donation } = await supabase
            .from("donations")
            .select("id")
            .eq("stripe_payment_intent_id", paymentIntent.id)
            .single();

          if (donation) {
            await supabase.from("donations").update({ status: "completed" }).eq("id", donation.id);

            // Update missionary current_support
            const { data: don } = await supabase.from("donations").select("missionary_id, amount").eq("id", donation.id).single();
            if (don) {
              await supabase.rpc("increment_missionary_support", {
                m_id: don.missionary_id,
                amt: don.amount,
              });
            }
          }
        }

        // Update donor stats
        const { data: donorData } = await supabase
          .from("donations")
          .select("donor_id, amount")
          .eq("stripe_payment_intent_id", paymentIntent.id)
          .single();

        if (donorData?.donor_id) {
          await supabase.rpc("update_donor_stats", { d_id: donorData.donor_id, amt: donorData.amount });
        }
        break;
      }

      case "payment_intent.payment_failed": {
        const paymentIntent = event.data.object;
        await supabase
          .from("donations")
          .update({ status: "failed" })
          .eq("stripe_payment_intent_id", paymentIntent.id);
        break;
      }
    }

    return new Response(JSON.stringify({ received: true }), { status: 200 });
  } catch (err) {
    return new Response(`Webhook Error: ${err.message}`, { status: 400 });
  }
});

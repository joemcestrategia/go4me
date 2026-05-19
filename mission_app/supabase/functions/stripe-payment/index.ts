import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@13.11.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { amount, currency, missionary_id, donor_id, project_id, is_recurring, is_anonymous } = await req.json();

    if (!amount || !currency) {
      throw new Error("amount and currency are required");
    }

    const amountInCents = Math.round(amount * 100);
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Registrar doação pendente primeiro para obter o ID
    const { data: donation } = await supabase
      .from("donations")
      .insert({
        donor_id: donor_id || null,
        missionary_id: missionary_id || null,
        project_id: project_id || null,
        amount: amount,
        currency,
        is_recurring: is_recurring ?? false,
        is_anonymous: is_anonymous ?? false,
        status: "pending",
      })
      .select("id")
      .single();

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInCents,
      currency: currency.toLowerCase(),
      metadata: {
        donation_id: donation?.id ?? "",
        missionary_id: missionary_id ?? "",
        donor_id: donor_id ?? "",
        project_id: project_id ?? "",
        is_recurring: String(is_recurring ?? false),
      },
      ...(is_recurring ? { setup_future_usage: "off_session" } : {}),
    });

    // Atualizar com o PaymentIntent ID
    if (donation) {
      await supabase
        .from("donations")
        .update({ stripe_payment_intent_id: paymentIntent.id })
        .eq("id", donation.id);
    }

    return new Response(
      JSON.stringify({
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
        donationId: donation?.id,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  }
});

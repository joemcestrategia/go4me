import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:go4me/core/theme/app_theme.dart';

class StripeTutorialPage extends StatelessWidget {
  const StripeTutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.hudTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('STRIPE CONFIGURATION'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'COMO RECEBER DOAÇÕES',
                style: AppTheme.hudTextTheme.displaySmall?.copyWith(
                  color: AppTheme.hudAccent,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn().slideX(begin: -0.1),
              
              const SizedBox(height: 8),
              
              Text(
                'Siga o protocolo abaixo para habilitar pagamentos globais em sua conta.',
                style: AppTheme.hudTextTheme.bodyMedium,
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 40),
              
              // Passos
              _buildStep(
                index: '01',
                title: 'CRIAR CONTA STRIPE',
                description: 'Acesse stripe.com e crie uma conta gratuita. O Stripe é o nosso processador de pagamentos oficial e seguro.',
                icon: Icons.account_balance_outlined,
                delay: 400.ms,
              ),
              
              _buildStep(
                index: '02',
                title: 'ATIVAR CONTA',
                description: 'Complete o perfil da sua organização ou perfil individual, fornecendo os detalhes bancários para recebimento.',
                icon: Icons.verified_user_outlined,
                delay: 600.ms,
              ),
              
              _buildStep(
                index: '03',
                title: 'OBTER CHAVES DE API',
                description: 'No painel do Stripe, vá em "Developers" > "API Keys". Você precisará da "Publishable Key" e da "Secret Key".',
                icon: Icons.vpn_key_outlined,
                delay: 800.ms,
              ),
              
              _buildStep(
                index: '04',
                title: 'VINCULAR AO GO4ME',
                description: 'Insira suas chaves na seção "Configurações de Pagamento" do seu dashboard para começar a receber suporte.',
                icon: Icons.sync_alt_outlined,
                isLast: true,
                delay: 1000.ms,
              ),
              
              const SizedBox(height: 48),
              
              // Botão de Ação
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Abrir site do Stripe
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('ABRIR CONTA NO STRIPE'),
                ),
              ).animate().fadeIn(delay: 1200.ms).shimmer(delay: 3000.ms),
              
              const SizedBox(height: 24),
              
              // Aviso de Segurança
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.hudAccent.withOpacity(0.05),
                  border: Border.all(color: AppTheme.hudAccent.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSharp),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: AppTheme.hudAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Suas chaves são criptografadas e nunca compartilhadas.',
                        style: AppTheme.hudTextTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppTheme.hudAccent.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 1400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required String index,
    required String title,
    required String description,
    required IconData icon,
    bool isLast = false,
    required Duration delay,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha lateral decorativa
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.hudAccent),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    index,
                    style: const TextStyle(
                      color: AppTheme.hudAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: AppTheme.hudAccent.withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 20),
          
          // Conteúdo do Passo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: AppTheme.hudAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: AppTheme.hudTextTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTheme.hudTextTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.1);
  }
}

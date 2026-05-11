/// Local FAQ item: question and answer.
class FaqItem {
  const FaqItem({
    required this.slug,
    required this.question,
    required this.answer,
  });

  /// Stable id for deep links (e.g. `?section=track`).
  final String slug;
  final String question;
  final String answer;
}

/// Provides a static list of local FAQs (e-commerce placeholder content).
class FaqDataSource {
  FaqDataSource._();

  static List<FaqItem> getFaqs() {
    return const <FaqItem>[
      FaqItem(
        slug: 'track',
        question: 'How do I track my order?',
        answer:
            'Once your order ships, you will receive an email with a tracking number and link. You can also view order status and tracking in the app under Profile → Order History. Tap an order to see its current status and delivery estimate.',
      ),
      FaqItem(
        slug: 'returns',
        question: 'What is your return policy?',
        answer:
            'We offer returns within 30 days of delivery for most items in their original condition. Start a return from Profile → Order History by selecting the order and tapping "Return items". Refunds are processed within 5–7 business days after we receive the returned item.',
      ),
      FaqItem(
        slug: 'change-order',
        question: 'How can I change or cancel my order?',
        answer:
            'If your order has not yet shipped, you may be able to cancel or change it from Order History. For shipped orders, you can request a return once the item arrives. Contact us via Profile → Contact Us if you need help with a recent order.',
      ),
      FaqItem(
        slug: 'payments',
        question: 'What payment methods do you accept?',
        answer:
            'We accept major credit and debit cards, and various local payment options depending on your country. At checkout you can choose your preferred method. All payments are processed securely.',
      ),
      FaqItem(
        slug: 'account',
        question: 'How do I update my account or password?',
        answer:
            'Go to Profile → Personal Details to edit your name, email, and phone. Use Profile → Change Password to set a new password. You will need your current password to complete the change.',
      ),
      FaqItem(
        slug: 'shipping-time',
        question: 'How long does shipping take?',
        answer:
            'Delivery times vary by location and shipping method. Standard delivery is typically 3–7 business days after dispatch. You can see estimated delivery dates in your cart and on the order confirmation page.',
      ),
      FaqItem(
        slug: 'security',
        question: 'Is my payment information secure?',
        answer:
            'Yes. We do not store your full card details. Payments are processed through secure, certified payment providers. Your data is encrypted and we follow industry standards to protect your information.',
      ),
      FaqItem(
        slug: 'support',
        question: 'How do I contact customer support?',
        answer:
            'Use Profile → Contact Us for phone, short code, and website. For quick help you can also use Profile → Help Desk. Our team is available to assist with orders, returns, and account questions.',
      ),
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:commercepal/core/constants/spacing.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: scheme.onSurface,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Terms & privacy',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Terms & privacy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Last updated: July 14, 2022',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: scheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: Spacing.xl),
            _buildClause(
              context,
              'Conditions of use',
              'By using CommercePal mobile apps, websites, and related services, you agree to follow these rules and all applicable laws. You are responsible for your account activity and for keeping your login credentials secure. We may update these conditions; continued use after changes means you accept the revised terms. For purchases, returns, and refunds, see our refund policy. The privacy notice below explains how we handle your personal information.',
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Privacy policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.md),
            // Introduction
            _buildClause(
              context,
              'Introduction',
                    'We know that you care how information about you is used and shared, and we appreciate your trust that we will do so carefully and sensibly. This Privacy Notice describes how Commercepal.com and its affiliates (collectively "CommercePal") collect and process your personal information through CommercePal websites, devices, products, services, online and physical stores, and applications that reference this Privacy Notice (together "CommercePal Services"). By using CommercePal Services, you are consenting to the practices described in this Privacy Notice.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // What Personal Information About Customers Does CommercePal Collect?
                  _buildClause(
                    context,
                    'What Personal Information About Customers Does CommercePal Collect?',
                    'We collect your personal information in order to provide and continually improve our products and services. Here are the types of personal information we collect:\n\n'
                    '• Information You Give Us. We receive and store any information you provide in relation to CommercePal Services. You can choose not to provide certain information, but then you might not be able to take advantage of many of our CommercePal Services.\n\n'
                    '• Automatic Information. We automatically collect and store certain types of information about your use of CommercePal Services, including information about your interaction with content and services available through CommercePal Services. Like many websites, we use "cookies" and other unique identifiers, and we obtain certain types of information when your web browser or device accesses CommercePal Services and other content served by or on behalf of CommercePal on other websites.\n\n'
                    '• Information from Other Sources. We might receive information about you from other sources, such as updated delivery and address information from our carriers, which we use to correct our records and deliver your next purchase more easily.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // For What Purposes Does CommercePal Use Your Personal Information?
                  _buildClause(
                    context,
                    'For What Purposes Does CommercePal Use Your Personal Information?',
                    'We use your personal information to operate, provide, develop, and improve the products and services that we offer our customers. These purposes include:\n\n'
                    '• Purchase and delivery of products and services. We receive and store any information you provide in relation to CommercePal Services. You can choose not to provide certain information, but then you might not be able to take advantage of many of our CommercePal Services.\n\n'
                    '• Provide, troubleshoot, and improve CommercePal Services. We use your personal information to provide functionality, analyze performance, fix errors, and improve the usability and effectiveness of the CommercePal Services.\n\n'
                    '• Recommendations and personalization. We use your personal information to recommend features, products, and services that might be of interest to you, identify your preferences, and personalize your experience with CommercePal Services.\n\n'
                    '• Comply with legal obligations. In certain cases, we collect and use your personal information to comply with laws. For instance, we collect from seller\'s information regarding place of establishment and bank account information for identity verification and other purposes.\n\n'
                    '• Communicate with you. We use your personal information to communicate with you in relation to CommercePal Services via different channels (e.g., by phone, email, chat).\n\n'
                    '• Advertising. We use your personal information to display interest-based ads for features, products, and services that might be of interest to you. We do not use information that personally identifies you to display interest-based ads.\n\n'
                    '• Fraud Prevention and Credit Risks. We use personal information to prevent and detect fraud and abuse in order to protect the security of our customers, CommercePal, and others. We may also use scoring methods to assess and manage credit risks.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // What About Cookies and Other Identifiers?
                  _buildClause(
                    context,
                    'What About Cookies and Other Identifiers?',
                    'To enable our systems to recognize your browser or device and to provide and improve CommercePal Services, we use cookies and other identifiers. For more information about cookies and how we use them, please read our Cookies Notice.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Does CommercePal Share Your Personal Information?
                  _buildClause(
                    context,
                    'Does CommercePal Share Your Personal Information?',
                    'Information about our customers is an important part of our business, and we are not in the business of selling our customers\' personal information to others. We share customers\' personal information only as described below and with subsidiaries Commercepal.com, Inc. controls that either are subject to this Privacy Notice or follow practices at least as protective as those described in this Privacy Notice.\n\n'
                    '• Transactions involving Third Parties. We make available to you services, products, applications, or skills provided by third parties for use on or through CommercePal Services. We also offer services or sell product lines jointly with third-party businesses, such as co-branded credit cards. You can tell when a third party is involved in your transactions, and we share customers\' personal information related to those transactions with that third party.\n\n'
                    '• Third-Party Service Providers. As we continue to develop our business, we might sell or buy other businesses or services. In such transactions, customer information generally is one of the transferred business assets but remains subject to the promises made in any pre-existing Privacy Notice (unless, of course, the customer consents otherwise). Also, in the unlikely event that Commercepal.com, Inc. or substantially all of its assets are acquired, customer information will of course be one of the transferred assets.\n\n'
                    '• Protection of CommercePal and Others. We release account and other personal information when we believe release is appropriate to comply with the law; enforce or apply our Conditions of Use and other agreements; or protect the rights, property, or safety of CommercePal, our users, or others. This includes exchanging information with other companies and organizations for fraud protection and credit risk reduction.\n\n'
                    '• Comply with legal obligations. In certain cases, we collect and use your personal information to comply with laws. For instance, we collect from seller\'s information regarding place of establishment and bank account information for identity verification and other purposes.\n\n'
                    'Other than as set out above, you will receive notice when personal information about you might be shared with third parties, and you will have an opportunity to choose not to share the information.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // How Secure Is Information About Me?
                  _buildClause(
                    context,
                    'How Secure Is Information About Me?',
                    'We design our systems with your security and privacy in mind.\n\n'
                    '• We work to protect the security of your personal information during transmission by using encryption protocols and software.\n\n'
                    '• We follow the Payment Card Industry Data Security Standard (PCI DSS) when handling credit card data.\n\n'
                    '• We maintain physical, electronic, and procedural safeguards in connection with the collection, storage, and disclosure of personal customer information. Our security procedures mean that we may occasionally request proof of identity before we disclose personal information to you.\n\n'
                    '• Our devices offer security features to protect them against unauthorized access and loss of data. You can control these features and configure them based on your needs.\n\n'
                    '• It is important for you to protect against unauthorized access to your password and to your computers, devices, and applications. Be sure to sign off when finished using a shared computer.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // What About Advertising?
                  _buildClause(
                    context,
                    'What About Advertising?',
                    '• Third-Party Advertisers and Links to Other Websites: CommercePal Services may include third-party advertising and links to other websites and apps. Third-party advertising partners may collect information about you when you interact with their content, advertising, and services. For more information about third-party advertising at CommercePal, including interest-based ads, please read our Interest-Based Ads policy. To adjust your advertising preferences, please go to the Advertising Preferences page.\n\n'
                    '• Use of Third-Party Advertising Services: We provide ad companies with information that allows them to serve you with more useful and relevant CommercePal ads and to measure their effectiveness. We never share your name or other information that directly identifies you when we do this. Instead, we use an advertising identifier like a cookie or other device identifier. For example, if you have already downloaded one of our apps, we will share your advertising identifier and data about that event so that you will not be served an ad to download the app again. Some ad companies also use this information to serve you relevant ads from other advertisers. You can learn more about how to opt-out of interest-based advertising by going to the Advertising Preferences page.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // What Information Can I Access?
                  _buildClause(
                    context,
                    'What Information Can I Access?',
                    'You can access your information, including your name, address, payment options, profile information, Prime membership, household settings, and purchase history in the "Your Account" section of the website.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // What Choices Do I Have?
                  _buildClause(
                    context,
                    'What Choices Do I Have?',
                    'If you have any questions as to how we collect and use your personal information, please contact our Customer Service. Many of our CommercePal Services also include settings that provide you with options as to how your information is being used.\n\n'
                    '• As described above, you can choose not to provide certain information, but then you might not be able to take advantage of many of the CommercePal Services.\n\n'
                    '• You can add or update certain information on pages such as those referenced in What Information Can I Access?. When you update information, we usually keep a copy of the prior version for our records.\n\n'
                    '• If you do not want to receive email or other communications from us, please adjust your Customer Communication Preferences. If you don\'t want to receive in-app notifications from us, please adjust your notification settings in the app or device.\n\n'
                    '• If you do not want to see interest-based ads, please adjust your Advertising Preferences.\n\n'
                    '• The Help feature on most browsers and devices will tell you how to prevent your browser or device from accepting new cookies or other identifiers, how to have the browser notify you when you receive a new cookie, or how to block cookies altogether. Because cookies and identifiers allow you to take advantage of some essential features of CommercePal Services, we recommend that you leave them turned on. For instance, if you block or otherwise reject our cookies, you will not be able to add items to your Shopping Cart, proceed to Checkout, or use any Services that require you to Sign in.\n\n'
                    '• If you want to browse our websites without linking the browsing history to your account, you may do so by logging out of your account here and blocking cookies on your browser.\n\n'
                    '• You will also be able to opt out of certain other types of data usage by updating your settings on the applicable CommercePal website (e.g., in "Manage Your Content and Devices"), device, or application. Most non-CommercePal devices also provide users with the ability to change device permissions (e.g., disable/access location services, contacts). For most devices, these controls are located in the device\'s settings menu.\n\n'
                    '• If you are a seller, you can add or update certain information in Seller Central, update your account information by accessing your Seller Account Information, and adjust your email or other communications you receive from us by updating your Notification Preferences.\n\n'
                    '• If you are an author, you can add or update the information you have provided in the Author Portal and Author Central by accessing your accounts in the Author Portal and Author Central, respectively.\n\n'
                    'In addition, to the extent required by applicable law, you may have the right to request access to or delete your personal data. If you wish to do any of these things, please contact Customer Service. Depending on your data choices, certain services may be limited or unavailable.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Are Children Allowed to Use CommercePal Services?
                  _buildClause(
                    context,
                    'Are Children Allowed to Use CommercePal Services?',
                    'CommercePal does not sell products for purchase by children. We sell children\'s products for purchase by adults. If you are under 18, you may use CommercePal Services only with the involvement of a parent or guardian. We do not knowingly collect personal information from children under the age of 13 without the consent of the child\'s parent or guardian.',
                  ),
                  const SizedBox(height: Spacing.lg),
                  // Examples of Information Collected
                  _buildClause(
                    context,
                    'Examples of Information Collected',
                    'Information You Give Us When You Use CommercePal Services. You provide information to us when you:\n\n'
                    '• search or shop for products or services in our stores;\n'
                    '• add or remove an item from your cart, or place an order through or use CommercePal Services;\n'
                    '• download, stream, view, or use content on a device or through a service or application on a device;\n'
                    '• provide information in Your Account (and you might have more than one if you have used more than one email address or mobile number when shopping with us) or Your Profile;\n'
                    '• upload your contacts;\n'
                    '• configure your settings on, provide data access permissions for, or interact with an CommercePal device or service;\n'
                    '• provide information in your Seller Account, Kindle Direct Publishing account, Developer account, or any other account we make available that allows you to develop or offer software, goods, or services to CommercePal customers;\n'
                    '• offer your products or services on or through CommercePal Services;\n'
                    '• communicate with us by phone, email, or otherwise;\n'
                    '• complete a questionnaire, a support ticket, or a contest entry form;\n'
                    '• upload or stream images, videos or other files to Prime Photos, CommercePal Drive, or other CommercePal Services;\n'
                    '• use our services such as Prime Video;\n'
                    '• compile Playlists, Watchlists, Wish Lists or other gift registries;\n'
                    '• participate in Discussion Boards or other community features;\n'
                    '• provide and rate Reviews;\n'
                    '• specify a Special Occasion Reminder; or\n'
                    '• employ Product Availability Alerts, such as Available to Order Notifications.\n\n'
                    'As a result of those actions, you might supply us with such information as:\n\n'
                    '• identifying information such as your name, address, and phone numbers;\n'
                    '• payment information;\n'
                    '• your age;\n'
                    '• your location information;\n'
                    '• your IP address;\n'
                    '• people, addresses and phone numbers listed in your Addresses;\n'
                    '• email addresses of your friends and other people;\n'
                    '• content of reviews and emails to us;\n'
                    '• personal description and photograph in Your Profile;\n'
                    '• images and videos collected or stored in connection with CommercePal Services;\n'
                    '• information and documents regarding identity, including Social Security and driver\'s license numbers;\n'
                    '• corporate and financial information;\n'
                    '• credit history information; and\n'
                    '• Device log files and configurations, including Wi-Fi credentials, if you choose to automatically synchronize them with your other CommercePal devices.\n\n'
                    'Automatic Information. Examples of the information we collect and analyze include:\n\n'
                    '• the internet protocol (IP) address used to connect your computer to the internet;\n'
                    '• login, email address, and password;\n'
                    '• the location of your device or computer;\n'
                    '• content interaction information, such as content downloads, streams, and playback details, including duration and number of simultaneous streams and downloads, and network details for streaming and download quality, including information about your internet service provider;\n'
                    '• device metrics such as when a device is in use, application usage, connectivity data, and any errors or event failures;\n'
                    '• CommercePal Services metrics (e.g., the occurrences of technical errors, your interactions with service features and content, your settings preferences and backup information, location of your device running an application, information about uploaded images and files such as the file name, dates, times and location of your images);\n'
                    '• version and time zone settings;\n'
                    '• purchase and content use history, which we sometimes aggregate with similar information from other customers to create features like Top Sellers;\n'
                    '• the full Uniform Resource Locator (URL) clickstream to, through, and from our websites, including date and time; products and content you viewed or searched for; page response times, download errors, length of visits to certain pages, and page interaction information (such as scrolling, clicks, and mouse-overs);\n'
                    '• phone numbers used to call our customer service number; and\n'
                    '• Images or videos when you shop in our stores, or stores using CommercePal Services.\n\n'
                    'We may also use device identifiers, cookies, and other technologies on devices, applications, and our web pages to collect browsing, usage, or other technical information.\n\n'
                    'Examples of information we receive from other sources include:\n\n'
                    '• updated delivery and address information from our carriers or other third parties, which we use to correct our records and deliver your next purchase or communication more easily;\n'
                    '• account information, purchase or redemption information, and page-view information from some merchants with which we operate co-branded businesses or for which we provide technical, fulfillment, advertising, or other services;\n'
                    '• information about your interactions with products and services offered by our subsidiaries;\n'
                    '• search results and links, including paid listings (such as Sponsored Links);\n'
                    '• Credit history information from credit bureaus, which we use to help prevent and detect fraud and to offer certain credit or financial services to some customers.\n\n'
                    'Information You Can Access:\n\n'
                    'Examples of information you can access through CommercePal Services include:\n\n'
                    '• status of recent orders (including subscriptions);\n'
                    '• your complete order history;\n'
                    '• personally identifiable information (including name, email, password, and address book);\n'
                    '• payment settings (including payment card information, promotional certificate and gift card balances, and 1-Click settings);\n'
                    '• email notification settings (including Product Availability Alerts, Delivers, Special Occasion Reminders and newsletters);\n'
                    '• recommendations and the products you recently viewed that are the basis for recommendations (including Recommended for You and Improve Your Recommendations);\n'
                    '• shopping lists and gift registries (including Wish Lists and Baby and Wedding Registries);\n'
                    '• your content, devices, services, and related settings, and communications and personalized advertising preferences;\n'
                    '• content that you recently viewed;\n'
                    '• voice recordings associated with your account;\n'
                    '• Your Profile (including your product Reviews, Recommendations, Reminders and personal profile);\n\n'
                    'If you are a seller, you can access your account and other information, and adjust your communications preferences, by updating your account in Seller Central.\n\n'
                    'If you are an author, you can access your account and other information, and update your accounts, on the Kindle Direct Publishing (KDP) or Author Central website, as applicable.\n\n'
                    'If you are a developer participating in our Developer Services Program, you can access your account and other information, and adjust your communications preferences, by updating your accounts in the Developer Services Portal.',
                  ),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildClause(BuildContext context, String title, String content) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: scheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}


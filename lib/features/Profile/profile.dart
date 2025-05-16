import 'package:expense_app/notifer/auth_notifer.dart';
import 'package:expense_app/provider/firebase.dart';
import 'package:expense_app/provider/item_provider.dart';
import 'package:expense_app/state/auth.dart';
import 'package:expense_app/utils/colors.dart';
import 'package:expense_app/utils/const.dart';
import 'package:expense_app/utils/loading.dart';
import 'package:expense_app/utils/routes.dart';
import 'package:expense_app/utils/setting_button.dart';
import 'package:expense_app/utils/text.dart';
import 'package:expense_app/utils/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expense_app/utils/string_app.dart';

import 'bottomsheet/setting_and_support.dart';

class ProfileScreen extends HookConsumerWidget {
  final PageController pageController;

  const ProfileScreen(this.pageController, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuth = ref.watch(firebaseAuthProvider);
    final itemProvider = ref.watch(cloudItemsProvider);
    final authState = ref.watch(authNotifierProvider);
    ref.listen(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        orElse: () => null,
        failed: (message) {
          EasyLoading.showError(message!);
        },
        success: (message) async {
          EasyLoading.showSuccess(message!);
          context.pushReplacement(AppRouter.authScreen);
        },
      );
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        PopScope(
            canPop: false,
            onPopInvoked: (value) => pageController.jumpToPage(0),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 5.sp)
                  .copyWith(top: 30.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    child: UserAvatar(firebaseAuth: firebaseAuth),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Gap(2.w),
                      TextWigdet(
                          text: firebaseAuth.currentUser?.displayName ??
                              "Guest User",
                          fontSize: 16.sp,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600),
                      Gap(1.w),
                      TextWigdet(
                          text: firebaseAuth.currentUser?.email ?? "None",
                          fontSize: 16.sp,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600),
                    ],
                  ),
                  Gap(2.h),
                  itemProvider.when(
                    data: (data) {
                      Map<String, int> lengths = calculateLengths(data);

                      return SizedBox(
                        width: double.infinity,
                        height: 25.h,
                        child: SfCircularChart(
                          margin: EdgeInsets.zero,
                          palette: const [
                            AppColor.kGreenColor,
                            AppColor.kredColor,
                            AppColor.kBlueColor
                          ],
                          series: <CircularSeries>[
                            DoughnutSeries<MapEntry<String, int>, String>(
                              dataSource: lengths.entries.toList(),
                              xValueMapper: (entry, _) => entry.key,
                              yValueMapper: (entry, _) => entry.value,
                              dataLabelMapper: (entry, _) =>
                                  '${entry.key}: ${entry.value}',
                              dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                  textStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                            ),
                          ],
                          legend: const Legend(isVisible: true),
                        ),
                      );
                    },
                    error: (_, __) => Text('error$__'),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  ),
                  Gap(1.h),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        CustomButton(
                          icons: LineIcons.barChart,
                          title: AppString.viewTimeline,
                          press: () => context.push(AppRouter.viewAllExpenses),
                        ),
                        CustomButton(
                          icons: LineIcons.phoenixFramework,
                          title: 'Setting & Support',
                          press: () => showModalBottomSheet(
                              context: context,
                              builder: (_) => const SettingAndSupport()),
                        ),
                        CustomButton(
                            icons: LineIcons.userCircle,
                            title: 'About us',
                            press: () => launchPortFolio()),
                        CustomButton(
                          icons: LineIcons.bookReader,
                          title: 'Privacy & Policy',
                          press: () => showModalBottomSheet(
                              context: context,
                              builder: (_) => const CommingSoon()),
                        ),
                        CustomButton(
                            icons: LineIcons.doorClosed,
                            title: 'Logout',
                            color: AppColor.kredColor,
                            press: () => ref
                                .read(authNotifierProvider.notifier)
                                .signOutGoogle()),
                      ],
                    ),
                  )
                ],
              ),
            )),
        if (authState == const AuthenticationState.loading())
          const LoadingWidget(),
      ],
    );
  }
}

class CommingSoon extends StatelessWidget {
  const CommingSoon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString().substring(0, 10)}',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Introduction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Welcome to Advanced Todo. We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and share your information when you use our app.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Information We Collect',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'When you use Advanced Todo, we may collect the following information:',
            ),
            const SizedBox(height: 12),
            const Text(
                '• Personal Information: Email address, name, and profile picture (if provided through Google Sign-In).\n'
                '• User Content: Task titles, descriptions, due dates, priorities, and other task-related data you create in the app.\n'
                '• Usage Data: Information about how you interact with the app, including features you use and time spent in the app.\n'
                '• Device Information: Device type, operating system, and unique device identifiers.'),
            const SizedBox(height: 24),
            const Text(
              'How We Use Your Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We use the information we collect to:',
            ),
            const SizedBox(height: 12),
            const Text(
                '• Provide, maintain, and improve the app\'s functionality.\n'
                '• Create and manage your account.\n'
                '• Store and sync your tasks across devices.\n'
                '• Send notifications and reminders you\'ve requested.\n'
                '• Respond to your comments, questions, and customer service requests.\n'
                '• Monitor and analyze trends, usage, and activity to improve the app.'),
            const SizedBox(height: 24),
            const Text(
              'Data Storage and Security',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
                'We use Firebase, a service provided by Google, to store and process your data. Firebase provides robust security measures to protect your information. Your tasks are stored in Cloud Firestore and are only accessible to you when you\'re signed in to your account.\n\n'
                'We implement appropriate technical and organizational measures to protect your personal data against unauthorized or unlawful processing, accidental loss, destruction, or damage.'),
            const SizedBox(height: 24),
            const Text(
              'Data Sharing and Third Parties',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We do not sell your personal information to third parties. We may share your information with:',
            ),
            const SizedBox(height: 12),
            const Text(
                '• Service Providers: Companies that help us deliver our services, such as Firebase (for data storage and authentication).\n'
                '• Legal Requirements: When required by law or to protect our rights and safety.\n'
                '• Business Transfers: In connection with a merger, acquisition, or sale of assets, your information may be transferred.'),
            const SizedBox(height: 24),
            const Text(
              'Your Rights and Choices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('You have the right to:\n\n'
                '• Access, correct, or delete your personal information.\n'
                '• Object to our processing of your data.\n'
                '• Export your task data.\n'
                '• Withdraw consent at any time (where processing is based on consent).\n\n'
                'To exercise these rights, you can use the app\'s settings or contact us using the information below.'),
            const SizedBox(height: 24),
            const Text(
              'Children\'s Privacy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
                'Our app is not directed to children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe that your child has provided us with personal information, please contact us.'),
            const SizedBox(height: 24),
            const Text(
              'Changes to This Privacy Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
                'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date. You are advised to review this Privacy Policy periodically for any changes.'),
            const SizedBox(height: 24),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
                'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                'Email: support@saucecode.com\n'
                'Website: https://saucecode.com/todo\n'),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

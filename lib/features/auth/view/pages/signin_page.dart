import 'package:client/core/theme/app_pallet.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/auth/view/pages/signup_page.dart';
import 'package:client/features/auth/view/widgets/custom_button.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/core/widgets/textfield.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/homePages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
        authViewModelProvider.select((value) => value?.isLoading == true));
    ref.listen(authViewModelProvider, (_, next) {
      next?.when(
          data: (data) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                  const SnackBar(content: Text("Login Successfully!")));
          },
          error: (error, st) {
            showSnakBar(error.toString(), context);
          },
          loading: () {});
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: isLoading == true
          ? const Center(
              child: Loader(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign In.',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextField(
                      hinttext: "Email",
                      controller: emailController,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomTextField(
                      isobsecuretext: true,
                      hinttext: "Password",
                      controller: passwordController,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CustomButtom(
                      ontap: () async {
                        if (formKey.currentState!.validate()) {
                          ref.read(authViewModelProvider.notifier).loginUser(
                              email: emailController.text,
                              password: passwordController.text);
                        }
                      },
                      text: "Sign In",
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()));
                      },
                      child: RichText(
                          text: TextSpan(
                        style: Theme.of(context).textTheme.titleMedium,
                        text: "Don't have an account? ",
                        children: const [
                          TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                  color: Pallete.gradient2,
                                  fontWeight: FontWeight.bold))
                        ],
                      )),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

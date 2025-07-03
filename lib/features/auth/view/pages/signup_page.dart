import 'package:client/core/theme/app_pallet.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/auth/view/pages/signin_page.dart';
import 'package:client/features/auth/view/widgets/custom_button.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/core/widgets/textfield.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
            showSnakBar("Account Created Successfully Please Login!", context);
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
      body: isLoading
          ? const Center(
              child: Loader(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      const Text(
                        'Sign Up.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 50),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CustomTextField(
                        hinttext: "Name",
                        controller: nameController,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        hinttext: "Email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      CustomTextField(
                        isobsecuretext: true,
                        hinttext: "Password",
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      CustomButtom(
                        ontap: () async {
                          if (formKey.currentState!.validate()) {
                            await ref
                                .read(authViewModelProvider.notifier)
                                .signUpUser(
                                    name: nameController.text,
                                    email: emailController.text,
                                    password: passwordController.text);
                          }
                        },
                        text: "Sign Up",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                        child: RichText(
                            text: TextSpan(
                          style: Theme.of(context).textTheme.titleMedium,
                          text: 'Already have an account? ',
                          children: const [
                            TextSpan(
                                text: 'Sign In',
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
            ),
    );
  }
}

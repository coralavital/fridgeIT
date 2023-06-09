// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables
import 'package:email_validator/email_validator.dart';
import 'package:fridge_it/ui/auth/reset_password.dart';
import 'package:fridge_it/widgets/custom_button.dart';
import 'package:fridge_it/widgets/custom_loader.dart';
import 'package:fridge_it/ui/auth/signup_page.dart';
import 'package:fridge_it/widgets/small_text.dart';
import 'package:fridge_it/widgets/text_field.dart';
import 'package:fridge_it/resources/auth_res.dart';
import 'package:fridge_it/theme/theme_colors.dart';
import 'package:fridge_it/ui/home/main_home.dart';
import 'package:fridge_it/utils/dimensions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final CustomLoader _loader = CustomLoader();
  bool showEmailError = false;
  bool showPasswordError = false;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void validatePassword(String password) {
    if (password.isEmpty) {
      showPasswordError = true;
    } else {
      showPasswordError = false;
    }
  }

  void validateEmail(String email) {
    if (!EmailValidator.validate(email) || email.isEmpty) {
      showEmailError = true;
    } else {
      showEmailError = false;
    }
  }

  String getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case "ERROR_WRONG_PASSWORD":
        return "Wrong email or password.";
      case "wrong-password":
        return "Wrong email or password.";
      case "ERROR_USER_NOT_FOUND":
        return "No user found with this email.";
      case "user-not-found":
        return "No user found with this email.";
      case 'Error while trying to login':
        return "Wrong email or password.";
      default:
        return "Wrong email or password.";
    }
  }

  login(String email, String password) async {
    String res = await AuthRes().login(email, password);
    if (res == 'success') {
      _loader.hideLoader();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainHome(),
        ),
      );
      Navigator.pop(context);
    } else {
      _loader.hideLoader();
      Fluttertoast.showToast(
        msg: getMessageFromErrorCode(res),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: ThemeColors().background,
        textColor: ThemeColors().main,
        fontSize: Dimensions.size15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors().background,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          // Status bar color
          systemNavigationBarColor: ThemeColors().background,
          statusBarColor: ThemeColors().background,
        ),
        backgroundColor: ThemeColors().background,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: ThemeColors().background,
          child: Column(
            children: [
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: Dimensions.size25,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors().green2,
                ),
              ),
              SizedBox(
                height: Dimensions.size20,
              ),
              Text(
                'Login to continue',
                style: TextStyle(
                  fontSize: Dimensions.size15,
                  color: ThemeColors().main,
                ),
              ),
              SizedBox(
                height: Dimensions.size20,
              ),
              Form(
                  onChanged: () {
                    String email = _email.text.toString().trim();
                    String password = _password.text.toString().trim();

                    validateEmail(email);
                    validatePassword(password);
                    setState(() {});
                  },
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(children: [
                    TextFieldWidget(
                      controller: _email,
                      hintText: 'Email',
                      prefixIcon: SvgPicture.asset(
                        'assets/icons/email.svg',
                        fit: BoxFit.none,
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.size5,
                    ),
                    showEmailError == true
                        ? SmallText(
                            color: Colors.red,
                            textAlign: TextAlign.start,
                            text: 'Please enter your email')
                        : SizedBox(
                            height: Dimensions.size5,
                          ),
                    TextFieldWidget(
                      controller: _password,
                      hintText: 'Password',
                      prefixIcon: SvgPicture.asset(
                        'assets/icons/lock.svg',
                        fit: BoxFit.none,
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.size5,
                    ),
                    showPasswordError == true
                        ? SmallText(
                            color: Colors.red,
                            textAlign: TextAlign.right,
                            text: 'Please enter your password\n')
                        : SizedBox(
                            height: Dimensions.size5,
                          ),
                  ])),
              SizedBox(
                height: Dimensions.size30,
              ),
              CustomButton(
                text: 'Login',
                onTap: () {
                  _loader.showLoader(context);
                  String email = _email.text.toString().trim();
                  String password = _password.text.toString().trim();
                  validateEmail(email);
                  validatePassword(password);
                  login(email, password);
                  if (!showEmailError && !showPasswordError) {
                    login(email, password);
                  } else {
                    _loader.hideLoader();
                    setState(() {});
                  }
                },
              ),
              SizedBox(
                height: Dimensions.size20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.size20),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        height: 1,
                        color: ThemeColors().green2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: Dimensions.size5, right: Dimensions.size5),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: ThemeColors().green2,
                          fontSize: Dimensions.size15,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        height: 1,
                        color: ThemeColors().green2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: Dimensions.size15,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignupPage(),
                      ));
                },
                child: Container(
                  height: Dimensions.size50,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Center(
                    child: Text('Create Account'),
                  ),
                ),
              ),
              SizedBox(
                height: Dimensions.size15,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPassword(),
                      ));
                },
                child: Container(
                  height: Dimensions.size50,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Center(
                    child: Text('Forgot password?'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

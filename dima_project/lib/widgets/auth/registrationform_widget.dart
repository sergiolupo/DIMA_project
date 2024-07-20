import 'package:dima_project/widgets/auth/loginform_widget.dart';
import 'package:flutter/cupertino.dart';

class PersonalInformationForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController usernameController;

  const PersonalInformationForm({
    required this.nameController,
    required this.surnameController,
    super.key,
    required this.usernameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoTextFormFieldRow(
            controller: nameController,
            padding: const EdgeInsets.all(12.0),
            placeholder: 'Name',
            decoration: BoxDecoration(
              color: CupertinoTheme.of(context).primaryContrastingColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null; // Return null if the input is valid
            },
            prefix: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                CupertinoIcons.person_crop_circle_fill,
                color: CupertinoColors.systemGrey,
              ),
            )),
        CupertinoTextFormFieldRow(
          controller: surnameController,
          padding: const EdgeInsets.all(12.0),
          placeholder: 'Surname',
          decoration: BoxDecoration(
            color: CupertinoTheme.of(context).primaryContrastingColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your surname';
            }
            return null; // Return null if the input is valid
          },
          prefix: const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(
              CupertinoIcons.person_crop_circle_fill,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
        UsernameInputTextField(usernameController),
      ],
    );
  }
}

class UsernameInputTextField extends StatelessWidget {
  final TextEditingController usernameController;

  const UsernameInputTextField(this.usernameController, {super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: usernameController,
      padding: const EdgeInsets.all(12.0),
      placeholder: 'Username',
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).primaryContrastingColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a username';
        }
        return null; // Return null if the input is valid
      },
      prefix: const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Icon(
          CupertinoIcons.person,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}

class CredentialsInformationForm extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController emailController;
  final TextEditingController confirmPasswordController;

  const CredentialsInformationForm({
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmailInputField(emailController),
        PasswordInputField(passwordController),
        PasswordInputField(
          confirmPasswordController,
          isConfirmPassword: true,
          confirmValue: passwordController,
        ),
      ],
    );
  }
}

import 'package:dima_project/widgets/login/loginform_widget.dart';
import 'package:flutter/cupertino.dart';

class PersonalInformationForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController surnameController;

  const PersonalInformationForm({
    required this.nameController,
    required this.surnameController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CupertinoTextFormFieldRow(
          controller: nameController,
          placeholder: 'Name',
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: CupertinoColors.systemGrey4,
              width: 2.0,
            ),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null; // Return null if the input is valid
          },
        ),
        const SizedBox(height: 16.0),
        CupertinoTextFormFieldRow(
          controller: surnameController,
          placeholder: 'Surname',
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: CupertinoColors.systemGrey4,
              width: 2.0,
            ),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a surname';
            }
            return null; // Return null if the input is valid
          },
        ),
      ],
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
        const SizedBox(height: 16.0),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:financebook/models/user.dart';
import 'package:financebook/services/authentication_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({
    Key? key,
    required this.authService,
  }) : super(key: key);
  static const String routeName = '/settings';
  final AuthenticationService authService;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late User user = User(username: '', password: '');
  late bool _isFormEnabled = false;

  Future<void> loadUser() async {
    try {
      final loadedUser = await widget.authService.getCurrentUser();
      if (loadedUser != null) {
        setState(() {
          user = loadedUser;
          _isFormEnabled = true;
        });
      } else {
        setState(() {
          _isFormEnabled = false;
        });
      }
    } catch (e) {
      // Handle error loading transactions
    }
  }

  final _key = GlobalKey<FormState>();
  late ChangePasswordFormState _state;
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;

  void _onOldPasswordChanged() {
    setState(() {
      _state = _state.copyWith(
          oldPassword: OldPassword.dirty(_oldPasswordController.text));
    });
  }

  void _onNewPasswordChanged() {
    setState(() {
      _state = _state.copyWith(
        newPassword: NewPassword.dirty(_newPasswordController.text),
      );
    });
  }

  Future<void> _onSubmit() async {
    if (!_key.currentState!.validate()) return;

    setState(() {
      _state = _state.copyWith(status: FormzSubmissionStatus.inProgress);
    });

    late String passwordWrongMessage = '';

    try {
      await _submitForm();
      _state = _state.copyWith(status: FormzSubmissionStatus.success);
    } catch (e) {
      _state = _state.copyWith(status: FormzSubmissionStatus.failure);
      if (e.toString().contains('Wrong password')) {
        passwordWrongMessage = 'Old password is wrong';
      }
    }

    if (!mounted) return;

    setState(() {});

    FocusScope.of(context)
      ..nextFocus()
      ..unfocus();

    const successSnackBar = SnackBar(
      content: Text('Kata sandi berhasil diubah!'),
    );

    SnackBar failureSnackBar = SnackBar(
      content: Text('Gagal mengubah kata sandi! $passwordWrongMessage'),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      _state.status.isSuccess ? successSnackBar : failureSnackBar,
    );

    if (_state.status.isSuccess) {
      _resetForm();
    }
  }

  Future<void> _submitForm() async {
    final username = user.username;
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;

    final checkPasswordResult =
        await widget.authService.checkUserPassword(username, oldPassword);

    if (!checkPasswordResult) {
      setState(() {
        _state = _state.copyWith(
          oldPassword: OldPassword.dirty(_oldPasswordController.text),
          status: FormzSubmissionStatus.failure,
        );
      });
      throw Exception('Kata sandi salah');
    }

    final changePasswordResult =
        await widget.authService.changePassword(username, newPassword);

    if (!changePasswordResult) {
      setState(() {
        _state = _state.copyWith(
          newPassword: NewPassword.dirty(_newPasswordController.text),
          status: FormzSubmissionStatus.failure,
        );
      });
      throw Exception('Gagal mengubah kata sandi');
    }

    await Future<void>.delayed(const Duration(seconds: 1));
  }

  void _resetForm() {
    _key.currentState!.reset();
    _oldPasswordController.clear();
    _newPasswordController.clear();
    setState(() => _state = const ChangePasswordFormState());
  }

  @override
  void initState() {
    super.initState();
    _state = const ChangePasswordFormState();
    _oldPasswordController =
        TextEditingController(text: _state.oldPassword.value)
          ..addListener(_onOldPasswordChanged);
    _newPasswordController =
        TextEditingController(text: _state.newPassword.value)
          ..addListener(_onNewPasswordChanged);
    loadUser().whenComplete(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Pengaturan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _key,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Ubah Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('changePasswordForm_oldPasswordInput'),
                      controller: _oldPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Password Lama',
                        errorMaxLines: 2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(
                              10.0)), // Menentukan bentuk border (misalnya, bulat)
                          borderSide: BorderSide(
                              color: Colors.purpleAccent), // Warna border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                              color: Colors
                                  .purpleAccent), // Ganti warna border ketika input aktif (diisi)
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                        labelStyle: TextStyle(color: Colors.white),

                      ),
                      validator: (value) =>
                          _state.oldPassword.validator(value ?? '')?.text(),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('changePasswordForm_newPasswordInput'),
                      controller: _newPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Password Baru',
                        errorMaxLines: 2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(
                              10.0)), // Menentukan bentuk border (misalnya, bulat)
                          borderSide: BorderSide(
                              color: Colors.purpleAccent), // Warna border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                              color: Colors
                                  .purpleAccent), // Ganti warna border ketika input aktif (diisi)
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      validator: (value) =>
                          _state.newPassword.validator(value ?? '')?.text(),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 24),
                    if (_state.status.isInProgress)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        key: const Key('changePasswordForm_submit'),
                        onPressed: _isFormEnabled ? _onSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,

                          elevation: 5,
                          padding: EdgeInsets.all(24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(200,
                              50), // Set the width and height of the button
                        ),
                        
                        child: const Text('Ubah Password'),
                      ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Color.fromARGB(255, 35, 35, 35),
                ),
                padding: const EdgeInsets.all(16),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/profile.png'),
                      radius: 40,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Nama   : Widiareta Safitri\n'
                        'NIM      : 1941720081\n'
                        'Kelas    : TI-4H\n'
                        'Tanggal: 02 Oktober 2023',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordFormState with FormzMixin {
  const ChangePasswordFormState({
    this.oldPassword = const OldPassword.pure(),
    this.newPassword = const NewPassword.pure(),
    this.status = FormzSubmissionStatus.initial,
  });

  final OldPassword oldPassword;
  final NewPassword newPassword;
  final FormzSubmissionStatus status;

  ChangePasswordFormState copyWith({
    OldPassword? oldPassword,
    NewPassword? newPassword,
    FormzSubmissionStatus? status,
  }) {
    return ChangePasswordFormState(
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      status: status ?? this.status,
    );
  }

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [oldPassword, newPassword];
}

enum OldPasswordValidationError { invalid, empty }

class OldPassword extends FormzInput<String, OldPasswordValidationError> {
  const OldPassword.pure([super.value = '']) : super.pure();

  const OldPassword.dirty([super.value = '']) : super.dirty();

  @override
  OldPasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return OldPasswordValidationError.empty;
    } else if (value.length < 8) {
      return OldPasswordValidationError.invalid;
    }
    return null;
  }
}

enum NewPasswordValidationError { invalid, empty }

class NewPassword extends FormzInput<String, NewPasswordValidationError> {
  const NewPassword.pure([super.value = '']) : super.pure();

  const NewPassword.dirty([super.value = '']) : super.dirty();

  @override
  NewPasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return NewPasswordValidationError.empty;
    } else if (value.length < 8) {
      return NewPasswordValidationError.invalid;
    }
    return null;
  }
}

extension on OldPasswordValidationError {
  String text() {
    switch (this) {
      case OldPasswordValidationError.invalid:
        return 'Kata sandi lama tidak valid, harus minimal 8 karakter';
      case OldPasswordValidationError.empty:
        return 'Kata Sandi Lama diperlukan';
    }
  }
}

extension on NewPasswordValidationError {
  String text() {
    switch (this) {
      case NewPasswordValidationError.invalid:
        return 'Kata sandi baru tidak valid, harus minimal 8 karakter';
      case NewPasswordValidationError.empty:
        return 'Kata Sandi Baru diperlukan';
    }
  }
}

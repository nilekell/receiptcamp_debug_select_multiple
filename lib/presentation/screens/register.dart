import 'package:flutter/material.dart';
import 'package:receiptcamp/presentation/widgets/auth/input_decor.dart';

class Register extends StatefulWidget {
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  // TextFormField state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Sign in'),
            onPressed: () {},
          )
        ],
        backgroundColor: Colors.blue,
        title: const Text('Register'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Container(
                  width: 250,
                  child: TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: 'email'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter an email' : null,
                    // value represents whatever is being typed into the form field
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 250,
                  child: TextFormField(
                    decoration:
                        textInputDecoration.copyWith(hintText: 'password'),
                    validator: (value) => value!.length < 6
                        ? 'Enter a password 6+ characters long'
                        : null,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () {}, child: const Text('Register')),
                const SizedBox(height: 20),
                Text(error,
                    style: const TextStyle(color: Colors.red, fontSize: 14)),
                ElevatedButton(
                    child: const Text('Login instead'),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }),
              ],
            )),
      ),
    );
  }
}

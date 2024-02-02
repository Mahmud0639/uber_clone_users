import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/widgets/loading_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userPhoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  CommonMethods commonMethods = CommonMethods();
  checkIfNetworkAvailable(){

      commonMethods.checkConnectivity(context);
      signUpFormValidation();
  }

  signUpFormValidation(){
    if(userNameController.text.trim().length<3){
      commonMethods.displaySnackBar("Your name must be at least 4 or more characters.", context);
      return;
    }else if(userPhoneController.text.trim().length<7){
      commonMethods.displaySnackBar("Your phone number must be at least 8 or more characters. ", context);
      return;
    }else if(!emailController.text.trim().contains("@")){
      commonMethods.displaySnackBar("Please write valid email", context);
      return;
    }else if(passController.text.trim().length<5){
      commonMethods.displaySnackBar("Password must be at least 6 or more characters.", context);
      return;
    }else{
      //register user
      registerNewUser();

    }


  }

  registerNewUser()async{
    showDialog(context: context,barrierDismissible: false, builder: (BuildContext context)=>LoadingDialog(messageTxt: "Registering your account..."));
   final User? userFirebase = (
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text.trim(), password: passController.text.trim()).catchError((errorMsg){
          Navigator.pop(context);//if any error occur then close the loading bar
          commonMethods.displaySnackBar(errorMsg.toString(), context);
        })
   ).user;
   if(!context.mounted) return;
   Navigator.pop(context);//if any error occur then close the loading bar

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);
    Map userDataMap = {
      "name": userNameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": userPhoneController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no"
    };


    userRef.set(userDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c)=>const HomePage()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset("assets/images/logo.png"),
              const Text(
                "Create a user's account",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              //Text Fields
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: userNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User name",
                        labelStyle: TextStyle(fontSize: 14),
                        hintText: "User name",
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 13,),
                    TextField(
                      controller: userPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "User phone",
                        labelStyle: TextStyle(fontSize: 14),
                        hintText: "Enter phone number",
                      ),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Email address",
                          labelStyle: TextStyle(fontSize: 14),
                          hintText: "Enter email"),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    TextField(
                      controller: passController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(fontSize: 14),
                          hintText: "Enter password"),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 30,),
                    ElevatedButton(
                        onPressed: () {
                          checkIfNetworkAvailable();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 80,vertical: 15)),
                        child: const Text("Sign Up")),

                    const SizedBox(height: 15,),

                    //textButton
                    TextButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoginScreen()));
                    }, child: const Text("Already have an account? Login Here",style: TextStyle(color: Colors.grey),))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

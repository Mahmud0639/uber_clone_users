import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/sign_up_screen.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/pages/home_page.dart';

import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();


  CommonMethods commonMethods = CommonMethods();
  checkIfNetworkAvailable(){

    commonMethods.checkConnectivity(context);
    signInFormValidation();
  }

  signInFormValidation(){
   if(!emailController.text.trim().contains("@")){
      commonMethods.displaySnackBar("Please write valid email", context);
      return;
    }else if(passController.text.trim().length<5){
      commonMethods.displaySnackBar("Password must be at least 6 or more characters.", context);
      return;
    }else{
      //login user
      loginUser();

    }


  }

  loginUser()async{
    showDialog(context: context,barrierDismissible: false, builder: (BuildContext context)=>LoadingDialog(messageTxt: "Registering your account..."));
    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text.trim(), password: passController.text.trim()).catchError((errorMsg){
          Navigator.pop(context);//if any error occur then close the loading bar
          commonMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;
    if(!context.mounted) return;
    Navigator.pop(context);//if any error occur then close the loading bar

    if(userFirebase != null){
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);
      usersRef.once().then((snap){//The once() method is likely used to read the data from the specified reference only once.
        if(snap.snapshot.value != null){
          //here user is exist, now we need to know that if user status is blocked or not
          if((snap.snapshot.value as Map)["blockStatus"]=="no"){
            userName = (snap.snapshot.value as Map)["name"];
            Navigator.push(context, MaterialPageRoute(builder: (c)=>const HomePage()));
          }else{
            //here user is exist but user status is blocked
            FirebaseAuth.instance.signOut();
            commonMethods.displaySnackBar("You are blocked. Please contact to company", context);
          }

        }else{
          FirebaseAuth.instance.signOut();
          commonMethods.displaySnackBar("You are not a valid user now.", context);
        }
      });
    }

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
                "Login as a user",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              //Text Fields
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

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
                        child: const Text("Login")),

                    const SizedBox(height: 15,),

                    //textButton
                    TextButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const SignUpScreen()));
                    }, child: const Text("Don't have an account? Register Here",style: TextStyle(color: Colors.grey),))
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

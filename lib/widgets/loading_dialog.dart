import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {

   String messageTxt;

   LoadingDialog({super.key,required this.messageTxt,});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      backgroundColor: Colors.black87,
      child: Container(
        margin: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(5)
        ),
        child:  Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const SizedBox(width: 3,),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(width: 3,),
              Text(messageTxt,style: const TextStyle(fontSize: 16,color: Colors.white),),
            ],
          ),
        ),
      ),
    );
  }
}

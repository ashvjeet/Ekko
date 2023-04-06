import 'package:flutter/material.dart';



TextField customTextField(String text, IconData icon, bool isPasswordType, TextEditingController controller){
  return TextField(
    onTap: ()=>{},
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.grey[800],
    style: TextStyle(
      color: Colors.grey.shade800.withOpacity(0.9)),
      decoration: InputDecoration(
      prefixIcon: Icon(
        icon, 
        color:Colors.grey[800],
        size: 17,
      ),
      labelText: text,
      labelStyle: TextStyle(color: Colors.grey.shade800.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          width: 0, 
          style: BorderStyle.none,
        ),
      ),
    ),
    keyboardType: isPasswordType 
    ? TextInputType.visiblePassword
    : TextInputType.emailAddress,
  );
}

ElevatedButton customButton(String text, Function onTap){
 return ElevatedButton(
    style: ElevatedButton.styleFrom(
      elevation: 10,
      backgroundColor: Colors.teal[300],
      minimumSize: Size(260, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      )
    ),
    onPressed: ()=>onTap(),
    child: Text(
      text, 
      style: TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.bold
      ),
    )
  );
}

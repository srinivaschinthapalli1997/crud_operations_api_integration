
import 'package:crud_app/services/todo_services.dart';
import 'package:flutter/material.dart';

import '../utils/snackbar_helpers.dart';
class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if(todo != null){
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(appBar: AppBar(title:  Text(isEdit ? 'Edit Todo' : 'Add Todo'),),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
      TextField(
        controller: titleController,
        decoration: const InputDecoration(hintText: 'Title'),
      ),
      TextField(
        controller: descriptionController,
        decoration: const InputDecoration(hintText: 'Description'),
        keyboardType: TextInputType.multiline,
        minLines: 5,
        maxLines: 8,
      ),
        const SizedBox(height: 30,),
        ElevatedButton(
            onPressed: (){
              isEdit ? updateData() : submitData();
            }, child: Text(isEdit ? 'Update': 'Submit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Background color
            foregroundColor: Colors.white // Foreground color
          ),
        )
    ],),);
  }

  Future<void> updateData() async {
    // Get the data from form
    final todo = widget.todo;
    if(todo == null){
      print('You can not call update without todo data');
      return;
    }
    final id = todo['_id'];
    // Submit update data to the server
    final Url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(Url);
    final isSuccess = await TodoServices.updateTodo(id, body);
    // show success or fail message based on status
    if(isSuccess){
      showSuccessMessage(context,  message: 'Updation Success');
    }else{
      showErrorMessage(context,  message: 'Updation Failed');
    }
  }
  Future<void> submitData() async {
    // Submit data to the server
    final isSuccess = await TodoServices.addTodo(body);
    // show success or fail message based on status
    if(isSuccess){
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage(context, message : 'Creation Success');
    }else{
      showErrorMessage(context,  message: 'Creation Failed');
    }
  }

  Map get body {
    // Get the data from form
    final title = titleController.text;
    final description = descriptionController.text;
    return {
      "title": title,
      "description": description,
      "is_completed": false
    };
  }
}

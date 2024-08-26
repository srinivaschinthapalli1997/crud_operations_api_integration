
import 'package:crud_app/screens/add_page.dart';
import 'package:crud_app/services/todo_services.dart';
import 'package:crud_app/widget/todo_card.dart';
import 'package:flutter/material.dart';

import '../utils/snackbar_helpers.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading =  true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.blue,
      title: const Center(child: Text('Todo List',style: TextStyle(color: Colors.white  ),))
    ),
    body: Visibility(
      visible: isLoading,
      child: Center(child: CircularProgressIndicator()),
      replacement: RefreshIndicator(
        onRefresh: fetchTodo,
        child: Visibility(
          visible: items.isNotEmpty,
          replacement: Center(child: Text('No Todo Items',style: Theme.of(context).textTheme.headlineLarge,)),
          child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(10),
              itemBuilder: (context, index){
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return TodoCard(
                    index: index,
                    item: item,
                    navigateEdit: navigateToEditPage,
                    deleteById: deleteById);
              }),
        ),
      ),
    ),
    floatingActionButton: Container(
      height: 40,
      child: FloatingActionButton.extended(backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(80.0),
        ),
        onPressed: (){
        navigateToAddPage();
      },
      label: Text('Add Todo'),),
    ),
    );
  }

  Future<void> navigateToAddPage()async{
    final route = MaterialPageRoute(builder: (context) => const AddTodoPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }
  Future<void> navigateToEditPage(Map item) async{
    final route = MaterialPageRoute(builder: (context) =>  AddTodoPage(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async{
   // Delete the item
    final isSuccess = await TodoServices.deleteById(id);
    if(isSuccess){
      // Remove item from the list
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    }else{
      // Show error
      showErrorMessage(context, message: 'Deletion Failed');
    }
  }

  Future<void> fetchTodo() async{
    final response = await TodoServices.fetchTodos();

    if(response != null){
      setState(() {
        items = response;
      });
    }else{
showErrorMessage(context, message: 'Something went wrong');
    }
    setState(() {
      isLoading = false;
    });
  }

  void showSuccessMessage(String message){
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

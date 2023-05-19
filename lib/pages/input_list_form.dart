import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http_sample_fire/components/message_dialog_widget.dart';
import '../model/person.dart';

class InputListForm extends StatefulWidget {
  const InputListForm({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<InputListForm> createState() => _InputListFormState();
}

class _InputListFormState extends State<InputListForm> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  late String messageTitle;
  late String messageBody;
  late String messageAction;
  bool isError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Nome',
                  ),
                  controller: nameController,
                  validator: (value) {
                    isError = true;
                    messageBody = "Erro, campo [Nome] deve ser preenchido";
                    messageAction = "Fechar";
                    messageTitle = "Atenção";
                    showMessageDialog();
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Idade',
                    hintText: 'Idade',
                  ),
                  controller: ageController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        ageController.text.isEmpty) {
                      isError = true;
                      messageAction = "Fechar";
                      messageTitle = "Erro";
                      messageBody = "Preencher os campos corretamente";
                      showMessageDialog();
                      return;
                    }
                    int age;
                    try {
                      age = int.parse(ageController.text);
                    } catch (e) {
                      isError = true;
                      messageTitle = "Erro";
                      messageAction = "Fechar";
                      messageBody = "Valor do campo [Idade] deve ser numérico";
                      showMessageDialog();
                      return;
                    }
                    final person = Person(nameController.text, age, '_');
                    await createPerson(person);
                    setState(() {});
                    nameController.clear();
                    ageController.clear();
                  },
                  child: const Text('Cadastrar'),
                ),
              ),
              Expanded(
                child: _buildListOfPerson(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createPerson(Person person) async {
    messageAction = "Fechar";
    messageTitle = "Cadastro";
    if (nameController.text.isEmpty) return;
    if (ageController.text.isEmpty) return;

    FirebaseFirestore.instance.collection("person").add({
      "name": person.name,
      "age": person.age,
    }).then((value) {
      final id = value.id;
      FirebaseFirestore.instance.collection("person").doc(id).update({
        "key": id,
      }).then((_) {
        isError = false;
        messageBody = "Cadastro efetuado com sucesso";
        showMessageDialog();
      }).catchError((_) {
        isError = true;
        messageBody = "Erro ao efetuar o cadastro";
        showMessageDialog();
      });
    }).catchError((_) {
      isError = true;
      messageBody = "Erro no servidor, verificar dados informados";
      showMessageDialog();
    });
  }

  Widget _buildListOfPerson() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("person").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            dynamic data;
            data = snapshot.data!.docs[index].data();
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[200]!,
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  key: ValueKey(data['key']),
                  leading: const Icon(Icons.person),
                  title: Text(data['name']!),
                  subtitle: Text(data['age']!.toString()),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final nameEditingController =
                            TextEditingController(text: data['name']);
                        final ageEditingController =
                            TextEditingController(text: data['age'].toString());

                        return AlertDialog(
                          title: const Text('Editar Dados'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: nameEditingController,
                                decoration: const InputDecoration(
                                  labelText: 'Nome',
                                  hintText: 'Nome',
                                ),
                              ),
                              TextFormField(
                                controller: ageEditingController,
                                decoration: const InputDecoration(
                                  labelText: 'Idade',
                                  hintText: 'Idade',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                final newName = nameEditingController.text;
                                final newAge =
                                    int.tryParse(ageEditingController.text) ??
                                        0;
                                if (newName.isNotEmpty && newAge != 0) {
                                  updateRecord(data['key'], newName, newAge);
                                  Navigator.pop(context);
                                }
                              },
                              child: Row(
                                children: const [
                                  Icon(Icons.save),
                                  Text('Salvar'),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showMessageDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return MessageDialogWidget(
          isError: isError,
          messageTitle: messageTitle,
          messageBody: messageBody,
          messageAction: messageAction,
        );
      },
    );
  }

  void updateRecord(String key, String newName, int newAge) {
    FirebaseFirestore.instance.collection('person').doc(key).update({
      'name': newName,
      'age': newAge,
    }).then((value) {
      isError = false;
      messageAction = 'Fechar';
      messageBody = 'Registro atualizado com sucesso';
      messageTitle = 'Manutenção de Registro';
      showMessageDialog();
    }).catchError((error) {
      isError = true;
      messageAction = 'Fechar';
      messageBody = 'Erro ao atualizar o registro';
      messageTitle = 'Manutenção de Registro';
      showMessageDialog();
    });
  }
}

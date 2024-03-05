import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/features/group/presentation/manager/group_tab_manager.dart';
import 'package:dayagenda/features/group/presentation/widgets/group_list_with_employees.dart';
import 'package:dayagenda/features/group/presentation/widgets/no_groups_description.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:flutter/material.dart';

class GroupTab extends StatefulWidget {
  GroupTab({super.key});

  @override
  State<GroupTab> createState() => _GroupTabState();
}

class _GroupTabState extends State<GroupTab> {
  final _newGroupTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _manager.subscribeToGroups();
  }

  @override
  void dispose() {
    _newGroupTextController.dispose();
    _manager.dispose();
    super.dispose();
  }

  final _manager = locate<GroupTabManager>();
  bool _isAddingGroup = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(
                height: 48,
                width: 48,
              ),
              Expanded(
                child: Text(
                  'Mis Grupos',
                  textAlign: TextAlign.center,
                  style: navBarHeadlineTextStyle,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isAddingGroup = true;
                  });
                  _manager.tapAddGroupIcon();
                },
                icon: const Icon(
                  Icons.add_circle_rounded,
                  size: 32,
                  color: kBlueAccentColor,
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: _manager.groups,
            builder: (context, groupsValue, child) {
              int id = 0;
              print('GroupTab.build.groupsValue: $groupsValue');
              if (groupsValue == null) {
                debugPrint('groupsValue is null');
                return _isAddingGroup ? const SizedBox() : const NoGroupsDescription();
              } else {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 280,
                    minHeight: 200,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (var group in groupsValue)
                        GroupListWithEmployees(
                          group: group,
                          id: id++,
                        ),
                    ],
                  ),
                );
              }
            },
          ),
          if (_isAddingGroup)
            Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _newGroupTextController,
                        validator: (value) => (value == null || value.isEmpty) ? 'Por favor, ingrese un nombre' : null,
                        style: navBarAccountEmailInputTextStyle,
                        decoration: InputDecoration(
                          hintText: 'Nombre del grupo',
                          hintStyle: navBarAccountEmailInputTextStyle.copyWith(color: kBlueAccentColor),
                          prefixIcon: const Icon(
                            Icons.group_add_outlined,
                            color: kBlueAccentColor,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: kBlueAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              // color: kBlueAccentColor,
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _manager.addGroup(_newGroupTextController.text);
                          }
                          setState(() {
                            _isAddingGroup = false;
                            _newGroupTextController.text = '';
                          });
                        },
                        child: Text('Agrega Grupo', style: navBarAccountButtonTitleTextStyle),
                      )
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}

import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/features/group/presentation/managers/no_grous_manager.dart';
import 'package:dayagenda/features/group/presentation/widgets/no_groups_description.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:flutter/material.dart';

class NoGroups extends StatelessWidget {
  NoGroups({super.key});
  final _manager = locate<NoGroupsManager>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            'Mis Grupos',
            style: navBarHeadlineTextStyle,
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: _manager.groups,
            builder: (context, groupsValue, child) {
              if (groupsValue == null) {
                return const NoGroupsDescription();
              } else {
                for (var group in groupsValue) {
                  return Text(group.name);
                }
                return const SizedBox();
              }
            },
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder(
            valueListenable: _manager.showAddGroupForm,
            builder: (context, addGroupValue, child) {
              if (addGroupValue) {
                return Column(
                  children: [
                    TextField(
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
                    SizedBox(height: 24),
                  ],
                );
              } else {
                return Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () => _manager.showAddGroupFrom(true),
                    icon: const Icon(
                      Icons.add_circle_rounded,
                      size: 32,
                      color: kBlueAccentColor,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

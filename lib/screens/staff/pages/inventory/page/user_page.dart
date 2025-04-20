
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:order_management_flutter_app/core/utils/responsive.dart';
import '../../../../../features/user/bloc/user_bloc.dart';
import '../../../../../features/user/model/user_model.dart';
import '../../../../../features/user/views/user_create_form.dart';
import '../../../../../features/user/views/user_detail.dart';
import '../../../../../features/user/views/user_list.dart';
import '../../../../../features/user/views/widgets/user_create_button.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _allUsers = [];
  UserModel? _selectedUser;
  bool _isCreatingUser = false;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(UserFetchStarted());
  }

  void _showFloorCreateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const UserCreateForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserFetchSuccess) {
          setState(() {
            _allUsers = state.users;
          });
        }
        if (state is UserCreateSuccess) {
          setState(() {
            _isCreatingUser = false;
          });
        }
      },
      child: _isCreatingUser
          ? SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCreatingUser = false;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/arrow_left.svg',
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              colors.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'Thêm sản phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // const UserCreateForm(),
                ],
              ),
            )
          : Column(
              children: [
                if (!Responsive.isMobile(context))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Spacer(),
                        UserCreateButton(
                          onPressed: _showFloorCreateDialog,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: _selectedUser == null ? 1 : 2,
                          child: UserList(
                            users: _allUsers,
                            isCompact: _selectedUser != null,
                            onUserSelected: (product) {
                              setState(() {
                                _selectedUser = product;
                              });
                            },
                          ),
                        ),
                        if (_selectedUser != null) ...[
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: UserDetail(
                              user: _selectedUser!,
                              onClose: () {
                                setState(() {
                                  _selectedUser = null;
                                });
                              },
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
    );
  }
}

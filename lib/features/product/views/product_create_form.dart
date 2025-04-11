import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/custom_toast.dart';
import '../bloc/product_bloc.dart';
import '../../category/bloc/category_bloc.dart';
import '../../category/model/category_model.dart';

class ProductCreateForm extends StatefulWidget {
  const ProductCreateForm({super.key});

  @override
  State<ProductCreateForm> createState() => _ProductCreateFormState();
}

class _ProductCreateFormState extends State<ProductCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  final bool _isLoading = false;

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(CategoryFetchStarted());
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Chọn nguồn ảnh'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Chụp ảnh'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme
        .of(context)
        .colorScheme;
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductCreateSuccess) {
          CustomToast.showToast(context, "Tạo sản phẩm thành công!",
              type: ContentType.success);
        }
        if (state is ProductCreateFailure) {
          CustomToast.showToast(context, "Tạo sản phẩm thất bại!",
              type: ContentType.failure);
        }
      },
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryFetchSuccess) {
            _categories = state.categories;
          }
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Thông tin sản phẩm',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                              hintText: 'Tên sản phẩm *',
                              fillColor: colors.background,
                              filled: true,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                BorderRadius.all(Radius.circular(30)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tên sản phẩm không thể để trống';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              value: _selectedCategoryId,
                              buttonStyleData: ButtonStyleData(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                                height: 50,
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                elevation: 0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        color: Colors.grey, width: 1)),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                ),
                              ),
                              onChanged: (String? value) {
                                setState(() => _selectedCategoryId = value);
                              },
                              items: _categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Text(category.name,
                                      style: const TextStyle(fontSize: 14)),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          PriceTextField(
                            controller: _priceController,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              hintText: 'Mô tả',
                              fillColor: colors.background,
                              filled: true,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                BorderRadius.all(Radius.circular(30)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hình ảnh sản phẩm',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  height: 250,
                                  width: 250,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DottedBorder(
                                    color: _imageFile == null
                                        ? Colors.grey
                                        : Colors.transparent,
                                    strokeWidth: 1,
                                    dashPattern: const [6, 3],
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        _imageFile != null
                                            ? ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          child: Image.file(
                                            _imageFile!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets.all(
                                                  10),
                                              height: 80,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                const BorderRadius
                                                    .all(
                                                    Radius.circular(
                                                        10)),
                                              ),
                                              child: SvgPicture.asset(
                                                'assets/icons/image.svg',
                                                colorFilter:
                                                const ColorFilter
                                                    .mode(Colors.grey,
                                                    BlendMode.srcIn),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                                'Nhấn để chọn ảnh'),
                                          ],
                                        ),
                                        if (_imageFile != null)
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _imageFile = null; // Xóa ảnh
                                                });
                                              },
                                              child: CircleAvatar(
                                                radius: 15,
                                                backgroundColor: Colors.black
                                                    .withOpacity(0.5),
                                                child: const Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.blue,
                            // hoặc bất kỳ màu nào bạn muốn
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            // tùy chỉnh chiều cao
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(30), // bo góc nếu muốn
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              String name = _nameController.text;
                              double price =
                              CurrencyFormatter.stringToDouble(
                                  _priceController.text);
                              String description =
                                  _descriptionController.text;
                              String categoryId = _selectedCategoryId!;
                              context
                                  .read<ProductBloc>()
                                  .add(ProductCreateStarted(
                                  name: name,
                                  price: price,
                                  description: description,
                                  categoryId: categoryId,
                                  isShown: true,
                                  imageFile: _imageFile
                              ));
                            }
                          },
                          child: _isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text(
                            'Tạo sản phẩm',
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

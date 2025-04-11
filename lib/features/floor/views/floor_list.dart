import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_management_flutter_app/features/floor/bloc/floor_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/responsive.dart';
import '../../floor/model/floor_model.dart';
import 'widgets/floor_list_item.dart';

class MyFloors extends StatelessWidget {
  final Function(String?) onFloorSelected;

  const MyFloors({super.key, required this.onFloorSelected});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FloorBloc()..add(FloorFetchStarted()),
      child: Responsive(
        mobile: FloorList(onFloorSelected: onFloorSelected),
        tablet: FloorList(onFloorSelected: onFloorSelected),
        desktop: FloorList(onFloorSelected: onFloorSelected),
      ),
    );
  }
}

class FloorList extends StatefulWidget {
  final Function(String?) onFloorSelected;

  const FloorList({super.key, required this.onFloorSelected});

  @override
  State<FloorList> createState() => _FloorListState();
}

class _FloorListState extends State<FloorList> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedIndex = 0;
      });
      widget.onFloorSelected(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FloorBloc, FloorState>(
      builder: (context, state) {
        if (state is FloorFetchInProgress) {
          return _buildSkeletonLoader(context);
        } else if (state is FloorFetchSuccess) {
          return _buildFloorList(state.floors);
        } else if (state is FloorFetchFailure) {
          return Center(child: Text('Error: ${state.error}'));
        }
        return Container();
      },
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
                right: defaultPadding, left: (index == 0 && Responsive.isMobile(context)) ? defaultPadding : 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: colors.secondary,
              ),
              width: 120,
              height: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 80,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 60,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloorList(List<FloorModel> floors) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: floors.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.only(
                  left: Responsive.isMobile(context) ? defaultPadding : 0,
                  right: defaultPadding),
              child: FloorListItem(
                floor: const FloorModel(
                  id: '',
                  name: "Tất cả",
                ),
                isSelected: selectedIndex == index,
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  widget.onFloorSelected(null);
                },
              ),
            );
          } else {
            final floor = floors[index - 1];
            return Padding(
              padding: const EdgeInsets.only(right: defaultPadding),
              child: FloorListItem(
                floor: floor,
                isSelected: selectedIndex == index,
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  widget.onFloorSelected(floor.name);
                },
              ),
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class SortAndFilterPopUp {
  List<SortAndFilterModel> data;

  SortAndFilterPopUp(this.data);

  void show({
    @required BuildContext context,
    ValueChanged<List<SortAndFilterModel>> onChanged,
  }) {
    ValueNotifier<List<SortAndFilterModel>> notifier =
        ValueNotifier<List<SortAndFilterModel>>(data);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return Container(
          height: 350,
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 20,
            bottom: 10,
          ),
          child: ValueListenableBuilder<List<SortAndFilterModel>>(
            valueListenable: notifier,
            builder: (BuildContext context, data, Widget child) {
              return ReorderableWrap(
                needsLongPressDraggable: false,
                alignment: WrapAlignment.spaceBetween,
                spacing: 10,
                onReorder: (int oldIndex, int newIndex) {
                  if (data[oldIndex].status == false) return;

                  List<SortAndFilterModel> lastTrues =
                      data.where((e) => e.status == true).toList();

                  if (lastTrues.isEmpty) {
                    return;
                  }

                  if (newIndex > data.indexOf(lastTrues.last)) {
                    return;
                  }

                  if (newIndex > oldIndex) {
                    data.insert(newIndex + 1, data[oldIndex]);
                    data.removeAt(oldIndex);
                  } else {
                    data.insert(newIndex, data[oldIndex]);
                    data.removeAt(oldIndex + 1);
                  }
                  notifier.value = data;
                  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                  notifier.notifyListeners();
                  onChanged(data);
                },
                children: List.generate(
                  data.length,
                  (index) {
                    return Container(
                      width: MediaQuery.of(context).size.width / 2 - 30,
                      child: Row(
                        children: [
                          Checkbox(
                            value: data[index].status,
                            onChanged: (newValue) {
                              {
                                print("BERHASIL DAPET");

                                SortAndFilterModel lastShown = data
                                        .where((e) => e.status == true)
                                        .toList()
                                        .isEmpty
                                    ? data.first
                                    : data
                                        .where((e) => e.status == true)
                                        .toList()
                                        .last;

                                int lastShownIndex = data.indexOf(lastShown);

                                print(
                                    "data terakhir = ${lastShown.name} + posisi terakhir = $lastShownIndex + listoverview index = ${data[index].name}");
                                print("posisi terakhir $lastShownIndex");

                                data[index].status = newValue;

                                if (newValue == false) {
                                  data.add(data[index]);
                                  data.removeAt(index);
                                }

                                if (newValue == true) {
                                  if (lastShownIndex > index) {
                                    data.insert(
                                        lastShownIndex +
                                            (lastShownIndex == 0 ? 0 : 1),
                                        data[index]);
                                    data.removeAt(index);
                                  } else {
                                    data.insert(
                                        lastShownIndex +
                                            (lastShownIndex == 0 ? 0 : 1),
                                        data[index]);
                                    data.removeAt(index + 1);
                                  }
                                }
                                notifier.value = data;
                                // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                notifier.notifyListeners();
                                onChanged(data);
                              }
                            },
                          ),
                          Expanded(
                            child: Container(
                              child: Text(data[index].name),
                            ),
                          ),
                          data[index].status == true
                              ? Icon(Icons.drag_handle_rounded)
                              : SizedBox(),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class SortAndFilterModel {
  String name;
  bool status;

  SortAndFilterModel({
    @required this.name,
    @required this.status,
  });
}

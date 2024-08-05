import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';

class Selector extends StatelessWidget {
  const Selector({
    super.key,
    required this.itemList,
    required this.onPressed,
  });

  final List<String> itemList;
  final ValueSetter<String> onPressed;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;
    return InfoPopupWidget(
      arrowTheme: const InfoPopupArrowTheme(
        arrowDirection: ArrowDirection.down,
      ),
      customContent: () => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: screenWidth * 0.5,
              height: screenHeight * 0.3,
              child: ListView.separated(
                itemCount: itemList.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      onPressed(itemList[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(itemList[index]),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Divider(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      child: const Text("Select"),
    );
  }
}

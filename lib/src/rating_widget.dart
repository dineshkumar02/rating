import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'rating_controller.dart';
import 'rating_cubit.dart';
import 'widgets/stars_widget.dart';

class RatingWidget extends StatefulWidget {
  final RatingController controller;
  const RatingWidget({Key? key, required this.controller}) : super(key: key);

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  final animationDuration = const Duration(milliseconds: 800);
  final animationCurve = Curves.ease;

  int selectedRate = 0;
  late RatingController controller = widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.listenStateChanges(context);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String get ratingSurvey {
    final options = [
      '',
      controller.ratingModel.ratingConfig.ratingSurvey1,
      controller.ratingModel.ratingConfig.ratingSurvey2,
      controller.ratingModel.ratingConfig.ratingSurvey3,
      controller.ratingModel.ratingConfig.ratingSurvey4,
      controller.ratingModel.ratingConfig.ratingSurvey5,
    ];
    return options.length > selectedRate ? options[selectedRate] : options.first;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RatingCubit, RatingState>(
      bloc: controller.ratingCubit,
      buildWhen: (previous, current) => current is LoadingState || previous is LoadingState,
      builder: (context, state) {
        final isLoading = state is LoadingState;
        return IgnorePointer(
          ignoring: isLoading,
          child: AnimatedPadding(
            duration: animationDuration,
            curve: animationCurve,
            padding: EdgeInsets.symmetric(horizontal: selectedRate == 0 ? 50 : 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                if (controller.ratingModel.title != null) ...{
                  Text(
                    controller.ratingModel.title!,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                },
                const SizedBox(height: 10),
                if (controller.ratingModel.subtitle != null) ...{
                  Text(controller.ratingModel.subtitle!),
                },
                const SizedBox(height: 20),
                AnimatedContainer(
                  duration: animationDuration,
                  curve: animationCurve,
                  width: selectedRate == 0 ? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width * 0.6,
                  child: FittedBox(
                    child: StarsWidget(
                      selectedColor: Colors.amber,
                      selectedLenght: selectedRate,
                      unselectedColor: Colors.grey,
                      length: 5,
                      onChanged: (count) {
                        setState(() => selectedRate = count);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Text(
                      ratingSurvey,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ArgonButton(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.3,
                        borderRadius: 5.0,
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Text(
                          "Save",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onErrorContainer),
                        ),
                        loader: Container(
                          padding: const EdgeInsets.all(10),
                          child: SpinKitRotatingCircle(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        onTap: (startLoading, stopLoading, btnState) async {
                          // If there is no rating, then just do nothing
                          if (selectedRate == 0) {
                            return;
                          }

                          if (btnState == ButtonState.Idle) {
                            startLoading();
                            await controller.ratingCubit.saveRate(selectedRate).then((_) {}).whenComplete(() {
                              stopLoading();
                              Navigator.of(context).pop();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }
}

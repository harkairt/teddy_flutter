import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:interactive_login/tracking_text_input.dart';
import 'package:rive/rive.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFFD6E2EA),
        body: LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final passwordFocusNode = useFocusNode();
    final controller = useState<StateMachineController>(StateMachineController(StateMachine()));
    final passwordController = useTextEditingController();

    final isObscured = useState(true);

    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        if (isObscured.value) {
          controller.value.handsUp();
        }
      } else {
        controller.value.handsDown();
      }
    });

    final usernameFocusNode = useFocusNode();
    usernameFocusNode.addListener(() {
      if (usernameFocusNode.hasFocus) {
        controller.value.lookAt(100);
      } else {
        controller.value.idle();
      }
    });

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 300,
              width: 300,
              child: RiveAnimation.asset(
                'teddy.riv',
                onInit: (art) {
                  controller.value =
                      StateMachineController.fromArtboard(art, 'State Machine 1') as StateMachineController;
                  art.addController(controller.value);
                  debugPrint(controller.value.inputs.toList().map((e) => (e.name, e.type, e.value)).toString());
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: <Widget>[
                  TrackingTextInput(
                    controller: useTextEditingController(),
                    focusNode: usernameFocusNode,
                    enable: true,
                    label: "Username",
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  TrackingTextInput(
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    enable: true,
                    label: "Password",
                    isObscured: isObscured.value,
                    suffixIcon: Material(
                      type: MaterialType.transparency,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          splashRadius: 20,
                          onPressed: () {
                            isObscured.value = !isObscured.value;
                            if (passwordFocusNode.hasFocus) {
                              if (isObscured.value) {
                                controller.value.handsUp();
                              } else {
                                controller.value.handsDown();
                              }
                            }
                          },
                          icon: Icon(
                            isObscured.value ? Icons.visibility_off : Icons.visibility,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 70,
              padding: EdgeInsets.only(top: 20),
              child: HookBuilder(
                builder: (context) {
                  final isLoading = useState(false);

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      controller.value.handsDown();
                      isLoading.value = true;
                      await Future<void>.delayed(const Duration(milliseconds: 1500));
                      isLoading.value = false;
                      if (passwordController.text == "admin") {
                        controller.value.success();
                      } else {
                        controller.value.fail();
                      }
                    },
                    child: Builder(
                      builder: (context) {
                        return isLoading.value
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                              )
                            : Text(
                                "Submit",
                                style: TextStyle(color: Colors.white),
                              );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on StateMachineController {
  void idle() {
    findInput<bool>("Check")?.change(false);
  }

  void lookAt(double value) {
    findInput<bool>("Check")?.change(true);
    findInput<double>("Look")?.change(value);
  }

  void handsUp() {
    findInput<bool>("Check")?.change(false);
    findInput<bool>("hands_up")?.change(true);
  }

  void handsDown() {
    findInput<bool>("Check")?.change(false);
    findInput<bool>("hands_up")?.change(false);
  }

  void success() {
    findInput<bool>("Check")?.change(false);
    findSMI<SMITrigger>("success")?.fire();
  }

  void fail() {
    findInput<bool>("Check")?.change(false);
    findSMI<SMITrigger>("fail")?.fire();
  }
}

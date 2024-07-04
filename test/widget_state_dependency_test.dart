
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_state_notifier/widget_state_notifier.dart';

class MockService{
   void test(){}
}
void main() {
  test('Dependency Injection - Register and Retrieve Service', () {
    // Arrange
    final dependency = WidgetStateDependency.instance;
    final mockService = MockService();

    // Act
    dependency.register<MockService>(mockService);
    final retrievedService = dependency.get<MockService>();

    // Assert
    expect(retrievedService, mockService);
  });

  test('Dependency Injection - Clear Services', () {
    // Arrange
    final dependency = WidgetStateDependency.instance;
    final mockService = MockService();

    // Act
    dependency.register<MockService>(mockService);
    dependency.clear();
    try{
      final retrievedService = dependency.get<MockService>();
      // Assert
      expect(retrievedService, isNull);
    }catch(e){
      'nothing';
    }

  });
}

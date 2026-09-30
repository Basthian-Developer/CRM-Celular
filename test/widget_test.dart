import 'package:flutter_test/flutter_test.dart';

import 'package:crm_celular/app.dart';

void main() {
  testWidgets('muestra el inicio del CRM', (tester) async {
    await tester.pumpWidget(const CrmApp());

    expect(find.text('CRM MINI'), findsOneWidget);
    expect(find.text('Tu resumen personal'), findsOneWidget);
    expect(find.text('Buenos días,'), findsOneWidget);
    expect(find.text('Contactos'), findsOneWidget);
  });
}

backend-run:
	cd services/api-server && mvn spring-boot:run

backend-test:
	cd services/api-server && mvn test

mobile-get:
	cd apps/mobile_app && flutter pub get

mobile-analyze:
	cd apps/mobile_app && flutter analyze

mobile-test:
	cd apps/mobile_app && flutter test

mobile-create-platforms:
	cd apps/mobile_app && flutter create .

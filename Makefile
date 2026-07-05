
.PHONY : test/end-to-end
test/end-to-end :
	@(flutter drive \
		--driver=test_driver/integration_test.dart \
		--target=integration_test/app_test.dart \
		-d web-server)

.PHONY : test/unit
test/unit :
	@(flutter test)

.PHONY : test
test: test/unit
test: test/end-to-end

.PHONY : run/web
run/web :
	@(flutter run \
		-d web-server)

.PHONY : run
run :
	@(flutter run)

.PHONY : clean
clean :
	@(flutter clean)

.PHONY : build
build : build/android
build : build/web

.PHONY : build/android
build/android :
	@(flutter build appbundle)

.PHONY : build/web
build/web :
	@(flutter build web)

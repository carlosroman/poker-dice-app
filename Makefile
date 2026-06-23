
.PHONY : test/end-to-end
test/end-to-end :
	@(flutter drive \
		--driver=integration_test/app_test_driver.dart \
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

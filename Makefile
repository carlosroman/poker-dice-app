
.PHONY : test/end-to-end
test/end-to-end :
	@(flutter drive   --driver=integration_test/app_test_driver.dart   --target=integration_test/app_test.dart   -d web-server)

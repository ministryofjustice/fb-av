ifdef TARGET
TARGETDEFINED="true"
else
TARGETDEFINED="false"
endif

dev:
	$(eval export env_stub=dev)
	@true

test:
	$(eval export env_stub=test)
	@true

live:
	$(eval export env_stub=live)
	@true

target:
ifeq ($(TARGETDEFINED), "true")
	$(eval export env_stub=${TARGET})
	@true
else
	$(info Must set TARGET)
	@false
endif

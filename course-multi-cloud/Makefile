MODULES = module-1-global-routing module-2-mesh-network module-3-nomad-federation module-4-distributed-data module-5-chaos-engineering

.PHONY: all test clean $(MODULES)

all: test

test: $(MODULES)

$(MODULES):
	$(MAKE) -C $@ test

clean:
	@for mod in $(MODULES); do \
		$(MAKE) -C $$mod clean; \
	done

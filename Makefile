default:
	@$(MAKE) install
	@vim

install:
	@cp ./autoload/* ~/.vim/autoload/
	@cp ./plugin/* ~/.vim/plugin/

lint:
	@vint autoload

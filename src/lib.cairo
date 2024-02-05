mod appchain;
mod interface;

// Components
mod config {
    mod interface;
    use interface::{IConfig, IConfigDispatcher, IConfigDispatcherTrait};

    mod component;
    use component::config_cpt;

    mod mock;
    use mock::config_mock;
}

mod mock;

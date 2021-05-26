module Configure

import TOML
import MetaEngine

const exp_config = TOML.tryparsefile("experiment.toml")

function config_state()
    state_signature = ""

    for (variable, type) in exp_config["state"]
        state_signature *= "$variable::$type "
    end

    @MetaEngine.state_factory(state_signature)
end

end

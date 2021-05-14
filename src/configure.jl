module Configure

import TOML
import MetaEngine

data = TOML.tryparsefile("experiment.toml")

function config_state()
    state_signature = ""

    for (variable,type) in data["state"]
        state_signature *= "$variable::$type "
    end

    schema = [(Symbol(variable),Symbol(titlecase(type))) (variable,type) in data["state"]]

    @MetaEngine.make_state state_signature
end

end

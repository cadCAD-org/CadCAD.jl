module Simulation

# Configure


function main()
    history = Vector{State}()

    initial_state = State(1, 1, 0.5, 0.5)

    push!(history, initial_state)

    for timestep = 1:N_STEPS
        for (substep, substep_block) in enumerate(timestep_block)
            for func in substep_block
                push!(history, func(history[end], timestep=timestep, substep=substep))
            end
        end
    end

end

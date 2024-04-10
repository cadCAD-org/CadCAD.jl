Using PyCall

# Level 1

function serial(blk1::Function, blk2::Function)
    return function (x)
        return blk2(blk1(x))
    end
end

function py_serial(blk1::Function, blk2::Function)
    # Call the serial function from python
    pyimport("my_blocks.py")
    py"my_blocks.py".blk2(blk1)
end

# Level 2

function =>(blk1::Function, blk2::Function)
    serial(blk1, blk2) # Pure julia call
    py_serial(blk1, blk2) # Pure python call
end

A_py => B_jl 
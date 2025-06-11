using Revise
using Dice
using Plots
using Distributions

# a = DistFix{4, 2}

# t = DistUInt{3}

# b = uniform(DistUInt{3})
# c = pr(b)
# plot(pr(b))

# a = DistFix{5, 1}
# b = bitblast(a, Normal(0, 1), 8, -4.0, 4.0)
# scatter(pr(b))

# NOTE: this currently does NOT work - "non-boolean used in boolean context", somewhere in isequals in the observe statement
code = @dice begin 
    println("STARTING")
    format = DistFix{4, 0}      # the second number being 0 restricts these to only integers
    normal_dist = Normal(0,1)
    num_pieces_for_approx = 8
    lower_bound = 0.0
    upper_bound = 8.0 # arbitrary, can pick whatever

    println("STOP 1")

    w0 = bitblast(format, normal_dist, num_pieces_for_approx, lower_bound, upper_bound)
    w0 = w0.mantissa
    w0 = DistUInt(w0.number.bits)

    println("STOP 2")

    w1 = bitblast(format, normal_dist, num_pieces_for_approx, lower_bound, upper_bound)
    w1 = w1.mantissa
    w1 = DistUInt(w1.number.bits)

    println("STOP 3")


    x = DistUInt{4}(1)
    y = DistUInt{4}(5)

    println("JUST BEFORE OBSERVE")
    observe(prob_equals(y, (w0 + w1*x)))
end


# TODO: note that this type of linear regression is only allowing weights of non-negative, and integer types
format = DistFix{4, 0}      # the second number being 0 restricts these to only integers
normal_dist = Normal(0,1)
num_pieces_for_approx = 8
lower_bound = 0.0
upper_bound = 8.0 # arbitrary, can pick whatever

w0 = bitblast(format, normal_dist, num_pieces_for_approx, lower_bound, upper_bound)
w0 = w0.mantissa
w0 = DistUInt(w0.number.bits)

w1 = bitblast(format, normal_dist, num_pieces_for_approx, lower_bound, upper_bound)
w1 = w1.mantissa
w1 = DistUInt(w1.number.bits)


x = DistUInt{4}(1)
y = DistUInt{4}(5)

# noise = bitblast(format, normal_dist, num_pieces_for_approx, lower_bound, upper_bound)
# noise = DistUInt( noise.mantissa.number.bits)
# observe(y = (w0 + w1*x + noise))

observe(prob_equals(y, (w0 + w1*x)))

code = @dice begin       # THIS HANGS  - don't run
    observe(prob_equals(y, (w0 + w1*x)))
end
@show pr(code)


(w0, w1)

# Basic idea:
# data (x1, y1) - cast to fixed point data point numbers. Just turn our data points into integers 
# set w's to have lower bound as 0
    # .mantissa.number
# y = w0 + w1x1
# for i in lenght of Data
#     observe (yi = (w0 + w1xi1 +w2xi2 + bitblast(... normal N(0,1 thing) )))

# (w0, w1)

    # w = dimension of data, i is number of data points 
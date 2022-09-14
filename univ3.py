import numpy as np
import matplotlib.pyplot as plt

#Rebalancing stables

#x1 is the initial amount of asset 1 and y1 is the initial amount of asset 2 
#here we assume that both assets have the same value
x1 = 1754
y1 = 32.24

#add the amount that you get for asset 2 after adding 100 of asset 1 in uniswap v3
a = 93.088  

x2 = 100*(x1+y1) / ( 100+a )
print (x2, "Final amount of asset 1")
#print (x1 - x2, "Amount you need to swap of asset 1")


y2 = a*(x1+y1) / ( 100+a )
print (y2, "Final amount of asset 2")

print (x1 - x2, "Swap amount")

#Impermanent loss on eth-link visor position

link_price = 7.11
eth_price = 1527
hodl = link_price / 30.11 * 546.5 + eth_price / 4081 * 546.5 
print ("hodl = ", hodl)


#Impermanent loss calculator 

#x= np.arange(0,10000,0.01)
x= np.arange(0.9,1.1,0.00001)

 
pb= 1.0081   #High price
pa = 1.0059  #Low price
p= 1.007   #price of asset when you added liquidity
pc = 1.0081 #current price



#last reposition
#pa = 900
#pb= 2400
#p=1457

 
ILV2 = 2 * np.sqrt(x) / (1 + x) - 1

#ILV3 = ILV2 * (       1.0 /  (1 - ( (np.sqrt(pa/p) + x * np.sqrt(p/pb)) /(1+x) )    )     )
def ILV3(x):
    return (2*np.sqrt(x) - np.sqrt(pa) - (x/np.sqrt(pb)) ) / ( np.sqrt(p) - np.sqrt(pa) + (1/np.sqrt(p) - 1/np.sqrt(pb)) * x) -1

plt.plot(x,ILV3(x))
plt.plot(pa,ILV3(pa),marker='o')
plt.plot(pb,ILV3(pb),marker='o')
print("Your impermanent loss in percentage is:", ILV3(pc))
#plt.plot(x,ILV2)
plt.ylim([-1,0])


#Weth usdc position
weth = 0.3223796 ## at 3258.91
usdc = 89.5





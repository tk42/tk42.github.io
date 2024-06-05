---
title: MarketProfile
feed: show
date: 2024-06-05
tags: 330/47,519/3,336/1,519/8,681/1
publish: true
---
> Market Profile is best understood as a way to see order in the markets.
>
>Each day the market will develop a range for the day along with a value area. This value area represents an equilibrium point between buyers and sellers. The “profile” follows a normal distribution curve.
>
>Volume is the key ingredient to understanding Market profile. If prices move away from their equilibrium (value area) and volume starts to dry up, it is likely that prices will move back into value.
>
>If price moves away from equilibrium on strong volume, this is a sign that traders are reevaluating the current value area as there has been a shift in sentiment.

![](https://i0.wp.com/eminimind.com/wp-content/uploads/2014/12/Distribution-Curve.jpg?w=305&ssl=1)

[The Ultimate Guide to Market Profile](https://eminimind.com/the-ultimate-guide-to-market-profile/)

>Market Profile is made up of TPO’s (Time Price Opportunities). A different letter is assigned to each 30-min time period of every trading session. I like to begin with A, but you will see varying charts start with different letters.

![](https://i0.wp.com/eminimind.com/wp-content/uploads/2014/12/Market-Profile-Breakdown.jpg?w=360&ssl=1)

> Let’s look at how we calculate value area using the TPO count.
>
>1. Count the total number of TPOs in a single day’s profile.
>2. Calculate 70% of this number.
>3. Identify the Point of Control (POC), the longest line of TPOs closest to the center of the profile. Note it’s TPO count.
>4. Add the TPOs of the two prices above and below the POC.
>5. Beginning with the larger number of combined two rows of TPOs, add this number to the POC number, continuing this process until the number reaches 70% of the total TPOs for the day (the resulting number from step 2).

> Example:
>
>- Total TPOs = 131
>- 70% of 131 = 92
>- TPOs at POC = 11
>- TPO Count = 11 + 20 + 18 + 16 + 14 + 9 + 6 = 94
>- Value Area Low = $2148
>- Value Area High = 2158

![Value Area Calculation](https://i0.wp.com/eminimind.com/wp-content/uploads/2014/12/Value-Area-Calculation.jpg?resize=215%2C344)


> A library to calculate Market Profile (Volume Profile) from a Pandas DataFrame. This library expects the DataFrame to have an index of `timestamp` and columns for each of the OHLCV values.

[Market Profile — Market Profile 0.2.0 documentation](https://marketprofile.readthedocs.io/en/latest/)

[GitHub - bfolkens/py-market-profile: A library to calculate Market Profile (aka Volume Profile) for financial data from a Pandas DataFrame.](https://github.com/bfolkens/py-market-profile/tree/master)

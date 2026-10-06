---
name: amazon-shopping
description: Rules for searching amazon.com for products. Load before any Amazon product search, whether through Chrome or a search URL. Triggers on "find X on Amazon", "search Amazon", "look this up on Amazon", "find a compatible part on Amazon", "what should I buy on Amazon".
---

# Amazon shopping

## Always filter to Prime and sort by Best Sellers

Every amazon.com search uses the Prime filter and the Best Sellers sort. (Tammer, 2026-10-06)

Append both parameters to the search URL:

```text
https://www.amazon.com/s?k=<query>&rh=p_85%3A2470955011&s=exact-aware-popularity-rank
```

`rh=p_85%3A2470955011` checks "All Prime" under Delivery. `s=exact-aware-popularity-rank` sets "Sort by: Best Sellers".

Check the results page shows "All Prime" checked and "Sort by: Best Sellers" before reading results. If either is missing, set it in the page.

Recommend from the top of that list. Skip a higher-ranked product only when it does not fit the need, and say why.

## Vehicle parts

Tammer's vehicles are saved in Amazon's garage. On the product page, set the "amazonconfirmedfit" picker to the right vehicle and require "This fits" before recommending a part. Switching the picker changes the vehicle Amazon filters by, so tell Tammer which vehicle it is left on.

## Buying

Never add to cart or buy without Tammer's explicit yes for that item.

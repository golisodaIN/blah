Hillary Clinton underperformed the (D) senate candidates
--

| state       | name     |     diff | party      | candidates           |
|---------------|------------|---------:|------------|----------------------|
| California    | H. Clinton | -2338906 | Democratic | K. Harris,L. Sanchez |
| New York      | H. Clinton |  -644500 | Democratic | C. Schumer           |
| Missouri      | H. Clinton |  -228333 | Democratic | J. Kander            |
| Kentucky      | H. Clinton |  -184388 | Democratic | J. Gray              |
| Washington    | H. Clinton |  -126365 | Democratic | P. Murray            |
| Indiana       | H. Clinton |  -125846 | Democratic | E. Bayh              |
| Oregon        | H. Clinton |  -104001 | Democratic | R. Wyden             |
| Connecticut   | H. Clinton |   -98577 | Democratic | R. Blumenthal        |
| Hawaii        | H. Clinton |   -37445 | Democratic | B. Schatz            |
| Colorado      | H. Clinton |   -34240 | Democratic | M. Bennet            |
| Alabama       | H. Clinton |   -19458 | Democratic | R. Crumpton          |
| Arkansas      | H. Clinton |   -19241 | Democratic | C. Eldridge          |
| Vermont       | H. Clinton |   -13677 | Democratic | P. Leahy             |
| New Hampshire | H. Clinton |    -6142 | Democratic | M. Hassan            |


Hillary Clinton did better than the (D) senate candidates
--

| state       | name     |     diff | party      | candidates           |
|---------------|------------|---------:|------------|----------------------|
| Idaho          | H. Clinton | 1573   | Democratic | J. Sturgill                                                                       |
| Wisconsin      | H. Clinton | 1714   | Democratic | R. Feingold                                                                       |
| Utah           | H. Clinton | 7395   | Democratic | M. Snow                                                                           |
| Maryland       | H. Clinton | 9106   | Democratic | C. Van Hollen                                                                     |
| South Dakota   | H. Clinton | 13317  | Democratic | J. Williams                                                                       |
| Nevada         | H. Clinton | 17095  | Democratic | C. Cortez Masto                                                                   |
| North Dakota   | H. Clinton | 35550  | Democratic | E. Glassheim                                                                      |
| Kansas         | H. Clinton | 46116  | Democratic | P. Wiesner                                                                        |
| Pennsylvania   | H. Clinton | 51037  | Democratic | K. McGinty                                                                        |
| North Carolina | H. Clinton | 59408  | Democratic | D. Ross                                                                           |
| Oklahoma       | H. Clinton | 64399  | Democratic | M. Workman                                                                        |
| Alaska         | H. Clinton | 64981  | Democratic | R. Metcalfe                                                                       |
| Illinois       | H. Clinton | 69135  | Democratic | T. Duckworth                                                                      |
| Louisiana      | H. Clinton | 84708  | Democratic | * |
| Arizona        | H. Clinton | 96533  | Democratic | A. Kirkpatrick                                                                    |
| South Carolina | H. Clinton | 97468  | Democratic | T. Dixon                                                                          |
| Iowa           | H. Clinton | 103816 | Democratic | P. Judge                                                                          |
| Georgia        | H. Clinton | 272294 | Democratic | J. Barksdale                                                                      |
| Florida        | H. Clinton | 380494 | Democratic | P. Murphy                                                                         |
| Ohio           | H. Clinton | 387128 | Democratic | T. Stricklan  





Donald Trump underperformed the (R) senate candidates
--

| state       | name     |     diff | party      | candidates           |
|---------------|------------|---------:|------------|----------------------|
| Ohio           | D. Trump | -276483 | Republican | R. Portman                                                                                   |
| Florida        | D. Trump | -216667 | Republican | M. Rubio                                                                                     |
| Utah           | D. Trump | -174777 | Republican | M. Lee                                                                                       |
| Iowa           | D. Trump | -124357 | Republican | C. Grassley                                                                                  |
| South Carolina | D. Trump | -85233  | Republican | T. Scott                                                                                     |
| Wisconsin      | D. Trump | -69795  | Republican | R. Johnson                                                                                   |
| Arizona        | D. Trump | -68119  | Republican | J. McCain                                                                                    |
| Kansas         | D. Trump | -60652  | Republican | J. Moran                                                                                     |
| Washington     | D. Trump | -59583  | Republican | C. Vance                                                                                     |
| North Dakota   | D. Trump | -51831  | Republican | J. Hoeven                                                                                    |
| Georgia        | D. Trump | -42114  | Republican | J. Isakson                                                                                   |
| Idaho          | D. Trump | -40143  | Republican | M. Crapo                                                                                     |
| South Dakota   | D. Trump | -37793  | Republican | J. Thune                                                                                     |
| Illinois       | D. Trump | -31920  | Republican | M. Kirk                                                                                      |
| Oklahoma       | D. Trump | -31794  | Republican | J. Lankford                                                                                  |
| North Carolina | D. Trump | -31589  | Republican | R. Burr                                                                                      |
| Maryland       | D. Trump | -25256  | Republican | K. Szeliga                                                                                   |
| Alabama        | D. Trump | -16259  | Republican | R. Shelby                                                                                    |
| Colorado       | D. Trump | -11654  | Republican | D. Glenn                                                                                     |
| Vermont        | D. Trump | -8198   | Republican | S. Milne                                                                                     |
| New Hampshire  | D. Trump | -7927   | Republican | K. Ayotte                                                                                    |
| Louisiana      | D. Trump | -7243   | Republican | * |


Donald Trump did better than the (R) senate candidates
--

| state       | name     |     diff | party      | candidates           |
|---------------|------------|---------:|------------|----------------------|
| Nevada         | D. Trump | 16892   | Republican | J. Heck                                                                                      |
| Alaska         | D. Trump | 19033   | Republican | L. Murkowski                                                                                 |
| Pennsylvania   | D. Trump | 19108   | Republican | P. Toomey                                                                                    |
| Arkansas       | D. Trump | 20048   | Republican | J. Boozman                                                                                   |
| Hawaii         | D. Trump | 34378   | Republican | J. Carroll                                                                                   |
| Kentucky       | D. Trump | 112791  | Republican | R. Paul                                                                                      |
| Connecticut    | D. Trump | 117867  | Republican | D. Carter                                                                                    |
| Oregon         | D. Trump | 126303  | Republican | M. Callahan                                                                                  |
| Indiana        | D. Trump | 133219  | Republican | T. Young                                                                                     |
| Missouri       | D. Trump | 215513  | Republican | R. Blunt                                                                                     |
| New York       | D. Trump | 775498  | Republican | W. Long     


BigQuery query
---

~~~~
SELECT a.state, a.name, MIN(a.votes)-SUM(b.votes) diff, MIN(a.individual_party) party, GROUP_CONCAT(b.name)
FROM [fh-bigquery:sheets.presidential_general_election_2016] a
JOIN [fh-bigquery:sheets.senate_general_election_2016] b
ON a.state=b.state AND a.individual_party=b.individual_party
WHERE a.name CONTAINS 'Trump'
GROUP BY 1,2
ORDER BY diff
LIMIT 1000
~~~~


Learn more:
- [Hillary Clinton only needed to switch 53,650 voters to win](https://medium.com/@hoffa/hillary-only-needed-to-switch-53-650-voters-to-win-94940ff263b7) (medium.com)



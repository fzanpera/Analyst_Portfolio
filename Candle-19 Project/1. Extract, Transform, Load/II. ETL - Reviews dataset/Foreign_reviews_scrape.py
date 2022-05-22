from matplotlib import pyplot
import pandas as pd
import requests
from bs4 import BeautifulSoup
import re
from secrets import randbelow

def get_soup(url):
    rnum = randbelow(10)
    r = requests.get('http://localhost:8050/render.html', params={'url': url, 'wait':rnum})
    soup = BeautifulSoup(r.text, 'html.parser')
    return soup
def get_reviews(soup):
    reviewlist = []
    reviews = soup.find_all('div',{'data-hook': 'review'})
    for item in reviews:
        try:
            review = {
            'product' : product.strip(),
            'brand' : brand.strip(),
#            'rev_title' : item.find('a', {'data-hook':'review-title'}).text.strip(),
            'rev_rating' : float(item.find('i',{'data-hook':'cmps-review-star-rating'}).text.replace('out of 5 stars','').strip()),
            'rev_loc' : re.findall(r'Reviewed in (.+) on ', item.find('span', {'data-hook':'review-date'}).text.strip())[0],
            'rev_dt' : re.findall(r' on ([0-9]{1,2} \w+ [0-9]{4})$', item.find('span', {'data-hook':'review-date'}).text.strip())[0],
            }
            reviewlist.append(review)
        except:
            pass
    return reviewlist



df_start = pd.read_excel("D:/OneDrive/Courses/Portfolio Project/Candle-19 project/candles_dataset.xlsx")
reviewlists = []
for row in df_start.itertuples():
    url = row.Links
    product = row.ProductName
    brand = row.Brand
    for x in range(1,500):
# For some reason amazon.co.uk and amazon.com (possibly others as well) stops loading reviews past page 500
        soup = get_soup(str(url)+"&pageNumber="+str(x)+"&sortBy=recent")
        print(f'Scraping page: {x}'+' for product '+product)
        for review in get_reviews(soup):
            reviewlists.append(review)
        print(product+' reviews dataset count is now '+str(len(reviewlists))+'.')
        if not soup.find('li', {'class': 'a-disabled a-last'}):
            pass
        else:
            break

df_reviews = pd.DataFrame(reviewlists)
df_reviews.to_csv('D:/OneDrive/Courses/Portfolio Project/Candle-19 project/tittle-less/reviews_dataset_foreign.csv',sep=';') 
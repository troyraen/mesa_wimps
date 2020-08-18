import pandas as pd
import numpy as np
from matplotlib import pyplot as plt

from plot_fncs import plotdir, cbcmap, get_hdf

def plot_m3p5_h1vage(hdf, modnums={}):
    plt.figure()
    ax = plt.gca()

    pvt = {'index':'model_number','columns':'cb','values':'center_h1'}
    args = {'loglog':True, 'color':[cbcmap(0), cbcmap(6)], 'ax':ax,
            'marker':'.'}

    hdf.pivot(**pvt).plot(**args)

    # highlight models with saved profiles
    args['marker'] = 'o'
    for cb, mods in modnums.items():
        hdf.loc[(hdf.cb==cb) & (hdf.model_number.isin(mods)),:].pivot(**pvt).plot(**args)

    # plt.xlim(1e6,hdf.star_age.max())
    plt.xlim(200,hdf.model_number.max())
    plt.ylim(1e-15,10)
    plt.grid()
    plt.title('3.5 Msun h1 center of saved profiles')
    plt.tight_layout()
    plt.savefig(plotdir+'/m3p5_h1vage.png')

def get_h1_for_p3(p3row, hdf=None):
    center_h1 = hdf.loc[hdf.model_number==p3row.model_number,'center_h1']
    return center_h1


def get_h1_v_age_pivot(mass,cb):
    """ get a center_h1 vs age df as a pivot table
        mass: list
        cb: int
    """
    hdf = pd.concat([get_hdf(cb, mass=m) for m in mass])
    hdf['mass'] = hdf.index.str.strip('m').str[:-2]
    pvt = {'index':'star_age','columns':'mass','values':'center_h1'}
    hp = hdf.pivot(**pvt)
    hp = hp.interpolate(method='index') # fill nans due to different star_age values between models
    return hp
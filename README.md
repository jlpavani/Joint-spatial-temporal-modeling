# Joint-spatial-temporal-modeling

Data and R code to support Pavani and Moraga (2022).  In this paper, we describe geographic and temporal patterns of two mosquito-borne diseases, dengue and chikungunya, and their possible risk factors in the Brazilian state of Ceará in 2017. To pursue this, we consider a Bayesian hierarchical spatio-temporal model for the joint analysis of both arboviruses. This specification also uses a Zero-Inflated Poisson (ZIP) model to overcome the high proportion of zeros. Moreover, it includes covariates as well as disease-specific and shared spatial and temporal effects, which are estimated and mapped to identify similarities among diseases.

## Citation

If you find this code helpful and use it in your work, please cite our paper:

> Pavani, J.; Moraga, P.: A Bayesian joint spatio-temporal model for multiple mosquito-borne diseases. *New Frontiers in Bayesian Statistics*, 69-77, 2022. [[DOI](https://doi.org/10.1007/978-3-031-16427-9_7})]

```bibtex
@InProceedings{Pavani2022,
    author    = {Jessica Pavani and Paula Moraga},
    editor    = {Raffaele Argiento and Federico Camerlenghi and Sally Paganin},
    title     = {A {B}ayesian joint spatio-temporal model for multiple mosquito-borne diseases},
    booktitle = {New Frontiers in Bayesian Statistics},
    year      = {2022},
    publisher = {Springer International Publishing},
    pages     = {69--77},
    doi       = {10.1007/978-3-031-16427-9_7},
}

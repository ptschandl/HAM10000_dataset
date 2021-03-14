# HAM 10000 Dataset Tools

<a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Creative Commons Lizenzvertrag" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/80x15.png" /></a>

This repository gives access to the tools created and used
for assembling the training dataset for the proposed HAM-10000
(*Human Against Machine with 10000 training images*)
study, which extending part 3 of the ISIC 2018
challenge. The dataset itself is available for download at the [Harvard dataverse](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/DBW86T) or the [ISIC-archive](https://isic-archive.com/#images).

<hr>

## Extract

Following technique was used to leverage image data
from PowerPoint slides, by extracting and ordering them with unique identifiers:
- [`extract/extract_pptx.py`](extract/extract_pptx.py): Extracts images and
corresponding IDs from \*.pptx Presentation slides

<hr>

## Filter

To more efficiently order large image sets of containing non-annotated overview
(_clinic_), closeup (_macro_) and dermatoscopic (_dsc_) images, we fine-tuned a
neural network to distinguish between those types automatically.

#### 1. Annotation
- [`filter/filter_annotation.py`](filter/filter_annotation.py): An
OpenCV based script to quickly annotate images within a subfolder into
different image types. Results are stored in a CSV-file with the option to
abort-and-resume annotation.


#### 2. Training
Training was performed in *Caffe / DIGITS* abstracting away many training
variables. We gained 1501 annotated images with the tool above and proceeded
to training: GoogLeNet pretrained on ImageNet (taken from the NVIDIA DIGITS 5
Model Store) was fine-tuned on three classes for 20 epochs, landing at a final
top-1 accuracy on the test-set of 98.68% (one _dermatoscopic_ image classified
as _macro_). The trained model files are provided in `./classify/caffe_model/*`

#### 3. Inference

- [`filter/filter_inference.py`](filter/filter_inference.py): Classifies all
jpg-files in a subfolder and writes image type prediction to a csv file. (Adapted
  code from the [NVIDIA GitHub repository](https://github.com/NVIDIA/DIGITS/tree/master/examples/classification))

<hr>

## Unify

Pathologic diagnoses in clinical practice are often non-standardized and
verbose. The notebook below depicts our boilerplate used on
different datasets to merge raw string data into a clean set of classes.

- [`unify/unify_diagnoses.ipynb`](unify/unify_diagnoses.ipynb) uses the *pandas*
library to clean and unify diagnosis texts of dermatologic lesions into a
confined set of diagnoses other or ambiguous classes. <br>
**Note:** The notebook contains only a subset of example terms for display purposes,
as regular expressions are optimized to fit a given dataset. Therefore, most
commonly the ones given will _not_ be ready to be applied on a new set out of the box.
Importantly, also the _order_ of relabeling diagnoses matter, so we highly
recommend manual checkup of relabeled diagnoses and stepwise iteration when
applying to a new dataset.

<hr>

## Standardise

To normalise image format without squeezing, one Bash/ImageMagick command was applied
to final images before data submission to the archive:

`find . -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.tiff -o -iname \*.tif \) -print0 | xargs -0 -n1 mogrify -strip -rotate "90<" -resize "600x450^" -gravity center -crop 600x450+0+0 -density 72 -units PixelsPerInch -format jpg -quality 100`

<hr>

## Segment

- [`segment/imagej_fiji_macros.ijm`](segment/imagej_fiji_macros.ijm) contains macros enabling an efficient workflow for loading, reviewing, correcting and creating binary segmentation masks. The masks needing review need to be created beforehand by other means. These macros were used, together with the neural network based on [this paper](https://doi.org/10.1016/j.compbiomed.2018.11.010), to create the segmentation masks for analyses in [Tschandl et al. 2020](https://doi.org/10.1038/s41591-020-0942-0).

<hr>

# Cite
If tools or data helped your research, please cite:

- Tschandl, P., Rosendahl, C. & Kittler, H. The HAM10000 dataset, a large collection of multi-source dermatoscopic images of common pigmented skin lesions. Sci. Data 5, 180161 doi:10.1038/sdata.2018.161 (2018).

```
@article{Tschandl2018_HAM10000,
  author    = {Philipp Tschandl and
               Cliff Rosendahl and
               Harald Kittler},
  title     = {The {HAM10000} dataset, a large collection of multi-source dermatoscopic
               images of common pigmented skin lesions},
  journal   = {Sci. Data},
  volume    = {5},
  year      = {2018},
  pages     = {180161},
  doi       = {10.1038/sdata.2018.161}
}
```

If you used the segmentation macros or resulting segmentation masks from [here](https://doi.org/10.7910/DVN/DBW86T/EGDUDF), please cite:

- Tschandl, P. et al. Human–computer collaboration for skin cancer recognition. Nat Med 26, 1229–1234 (2020). https://doi.org/10.1038/s41591-020-0942-0 

```
@article{Tschandl2020_NatureMedicine,
  author = {Philipp Tschandl and Christoph Rinner and Zoe Apalla and Giuseppe Argenziano and Noel Codella and Allan Halpern and Monika Janda and Aimilios Lallas and Caterina Longo and Josep Malvehy and John Paoli and Susana Puig and Cliff Rosendahl and H. Peter Soyer and Iris Zalaudek and Harald Kittler},
  title = {Human{\textendash}computer collaboration for skin cancer recognition},
  journal = {Nature Medicine},
  volume = {26},
  number = {8},
  year = {2020},
  pages = {1229--1234},
  doi = {10.1038/s41591-020-0942-0},
  url = {https://doi.org/10.1038/s41591-020-0942-0}
}
```





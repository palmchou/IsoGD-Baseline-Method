ConGD baseline
---
This is the source code of the baseline method of [IsoGD](http://www.cbsr.ia.ac.cn/users/jwan/database/isogd.html),
a large-scale isolated gesture dataset.
Baseline method: MFSK features -> Kmeans -> SVM

## ChaLearn Challenge and Data downloading
The [ChaLearn LAP Large-scale Isolated Gesture Recognition Challenge](https://competitions.codalab.org/competitions/10331)
is in progress, please feel free to participate!  
You can gain access to the ChaLearn LAP IsoGD dataset from http://www.cbsr.ia.ac.cn/users/jwan/database/isogd.html.

## Notes
This code was tested on Ubuntu 14.04 OS, with MATLAB 2013b and Python 2.7. There is a compiled MFSK binary program for Ubuntu 14.04.  
Please double check the paths in code before your run it.

##Steps in detail of baseline method:

####Step 1. Extract MFSK Features.
For both `train_list.txt` and `valid_list.txt` use `isogd/batch_MFSK_feature_isogd.m` program to extract and save MFSK for all videos.

####Step 2. Calculate Kmeans Center and Save Hists
Excutes `joewan_upload_V2/joewan_code/iso_cal_center_and_get_hists.m` program to do all the works. It first randomly selects 20 videos for each class in train set, and uses features of these videos to calculate the center. When the center is ready, it will calculate and save the hist using the MFSK features of each video in both train set and validation set.

####Step 3. Use Lib-SVM to Train SVM Model and Predict the Label of Validation Hists.
First scale both `train.hist` and `valid.hist` to range `[-1, 1]`, using command`svm-scale`. Then train svm with linear kernel type `svm-train -t 0`. At last, use trained model to generate labels for `valid.hist`.

####Step 4. Format svm prediction
Run `isogd/evaluate.py` to get formatted result for evaluation.

##Citation
If you use this code in your research, please cite the following two papers:

**MFSK feature:**  
Jun Wan, Guogong Guo, Stan Z. Li, "Explore Efficient Local Features form RGB-D Data for One-shot Learning Gesture Recognition", in IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 38, no. 8, pp. 1626-1639, 2016.

**ConGD result:**  
Jun Wan, Yibing Zhao, Shuai Zhou, Isabelle Guyon, Sergio Escalera and Stan Z. Li, "ChaLearn Looking at People RGB-D Isolated and Continuous Datasets for Gesture Recognition", CVPR workshop, 2016.

Should you have any question, please contact:  
Shuai Zhou: shuaizhou.palm@gmail.com, or  
Jun Wan: jun.wan@ia.ac.cn

##License
### VLFeat
The kmeans algorithm we used is implemented by VLFeat toolbox.
> **VLFeat** is distributed under the BSD license:
> Copyright (C) 2007-11, Andrea Vedaldi and Brian Fulkerson
> Copyright (C) 2012-13, The VLFeat Team
> All rights reserved.

### ConGD Baseline
Distributed under the Apache License V2.0, please check `LICENSE` for further information.
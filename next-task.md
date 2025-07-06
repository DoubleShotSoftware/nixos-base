The next task is to introduce a gitea action to update the flake lock every 3 days.

Gitea doesn't follow the typical determinate systems github action due to a bug in the api to create a pull request
Additionally I want it to auto sync to main

I pulled a reference gitea action from a github issues

./update.yml

The source github issues explaining the discrepancy

https://github.com/DeterminateSystems/update-flake-lock/issues/117


I want to auto commit to main over open a pr

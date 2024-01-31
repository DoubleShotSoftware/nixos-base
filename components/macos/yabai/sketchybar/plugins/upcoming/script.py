#!/usr/bin/env python3

import os, subprocess, re, datetime


class Event:
    def __init__(self, title, diff, ongoing, time, url):
        self.title = title
        self.title_cut = self.title[:100].strip()
        self.diff = diff
        self.human_diff = ":".join(str(self.diff).split(":")[:-1])
        self.ongoing = ongoing
        self.time = time
        self.url = url
        if self.ongoing:
            self.human_str = f"{self.title_cut} {self.human_diff} left"
        else:
            self.human_str = f"{self.title_cut} in {self.human_diff}"

    def __repr__(self):
        return f"Event(title: {self.title}, diff: {self.diff}, ongoing: {self.ongoing}, time: {self.time}, url: {self.url})"


def get_events():
    datetime_format = "%d/%m/%Y %I:%M %p"
    now = datetime.datetime.now()
    url_pattern = r"(https|http)(://[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b[-a-zA-Z0-9()@:%_\+.~#?&//=]*)"
    cmd = "icalBuddy -n -nc -nrd -npn -ea -ps '/|/' -nnr '' -b '' -ab '' -iep 'title,notes,datetime' eventsToday"
    output = subprocess.Popen(
        cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    ).communicate()[0]
    lines = output.decode("utf-8").strip().split("\n")

    events = []
    if lines == [""]:
        return events

    for line in lines:
        splat = line.split("|")
        title = splat[0]

        urls = re.findall(url_pattern, splat[1])
        if len(urls) > 0:
            url = "".join((urls + [None])[0])

            timerange = splat[-1].replace("at ", "")
            starttime, endtime = timerange.split(" - ")
            endtime = datetime.datetime.strptime(
                f"{now.day}/{now.month}/{now.year} {endtime}", datetime_format
            )
            starttime = datetime.datetime.strptime(
                f"{now.day}/{now.month}/{now.year} {starttime}", datetime_format
            )

            ongoing = starttime <= now <= endtime
            if ongoing:
                diff = endtime - now
            else:
                diff = starttime - now

            time = " ".join(timerange.split()[3:])
            events.append(Event(title, diff, ongoing, time, url))
        else:
            url = None

    return events


def generate_main_text(events):
    next_event_text = (
        " > " + events[1].human_str if (len(events) > 1 and events[0].ongoing) else ""
    )
    return events[0].human_str + next_event_text


def plugin_undraw():
    args = [
        "--set upcoming drawing=off",
        #      '--set "seperator_upcoming" drawing=off',
    ]
    os.system("sketchybar -m " + " ".join(args))


def plugin_draw(main_text, popup_items):
    args = [
        f'--set upcoming label="{main_text}"',
        "--set upcoming drawing=on",
    ]

    for i, item in enumerate(popup_items):
        args += [
            f"--add item upcoming.{i} popup.upcoming",
            f"--set upcoming.{i} background.padding_left=10",
            f"--set upcoming.{i} background.padding_right=10",
            f'--set upcoming.{i} label="{item["text"]}"',
        ]
        if "url" in item and item["url"] is not None:
            args += [
                f'--set upcoming.{i} click_script="open -a Firefox {item["url"]} ; sketchybar -m --set upcoming popup.drawing=off"'
            ]

    os.system("sketchybar -m " + " ".join(args))


if __name__ == "__main__":
    events = get_events()
    if len(events) == 0:
        plugin_undraw()
    else:
        main_text = generate_main_text(events)
        plugin_draw(main_text, ({"text": e.human_str, "url": e.url} for e in events))

# octalpdf

this is just a simple program i mocked up in an afternoon to help me make little booklets from a pdf

it works by printing each page a certain way so you fold a piece of paper giving 8 pages on a single piece of paper that can be read like a book

## proof

### pdf made by the program

![image](https://github.com/user-attachments/assets/eab88300-063b-4b4e-9c52-504a4d891815)

### pdf printed out, folded, cut on edges, and stapled

<img src="https://github.com/user-attachments/assets/13c6664c-7797-41cb-9824-99d482f9f931" width=15%>
<img src="https://github.com/user-attachments/assets/4414b9de-834f-4a4f-a645-066fc37242eb" width=15%>
<img src="https://github.com/user-attachments/assets/8fb0eff0-f7ac-472e-a2f8-915d0719d4d1" width=15%>
<img src="https://github.com/user-attachments/assets/4023172a-efef-4d84-8717-a2f6ccf10144" width=15%>
<img src="https://github.com/user-attachments/assets/c5374caf-626c-4ae1-828f-03487ca36f86" width=15%>

## installation

### adding to ~/.local/bin

```bash
curl https://raw.githubusercontent.com/notwithering/octalpdf/refs/heads/main/octalpdf.sh > ~/.local/bin/octalpdf
chmod +x ~/.local/bin/octalpdf
```

# prerequisites

- awk
- ghostscript
- grep
- pdfjam (of texlive-core)
- pdftk

```bash
pacman --needed -S awk ghostscript grep texlive-core pdftk
```